# frozen_string_literal: true

shared_examples "map can be hidden" do
  it "checkbox hides the map" do
    fill_in_geocoding :proposal_address, with: address

    expect(page).to have_content("You can move the point on the map")

    check "proposal_has_no_address"

    expect(page).to have_no_content("You can move the point on the map")
  end
end

shared_examples "map can be shown" do |fill|
  it "checkbox shows the map" do
    fill_proposal(extra_fields: false) if fill

    expect(page).to have_no_content("You can move the point on the map")

    fill_in_geocoding :proposal_address, with: address

    expect(page).to have_content("You can move the point on the map")
  end
end

shared_examples "reuses draft if exists" do
  let!(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: proposal_title, body: proposal_body) }

  it "redirects to publish" do
    visit_component
    click_on "New proposal"

    expect(page).to have_content("Edit proposal draft")
    within ".wizard-steps" do
      expect(page).to have_content("Create your proposal")
      expect(page).to have_content("Compare")
      expect(page).to have_content("Publish your proposal")
    end
  end
end

shared_examples "customized form" do
  context "when only_photo_attachments is enabled" do
    let(:only_photos) { true }

    it "does not show the attachments" do
      uncheck "proposal_has_no_image"
      expect(page).to have_no_content("Add an attachment")
      expect(page).to have_content("Image/photo")
    end

    context "and attachment are not active" do
      let(:attachments) { false }

      it "does not show the attachments or photos" do
        expect(page).to have_no_checked_field("proposal_has_no_image")
        expect(page).to have_no_content("Add an attachment")
        expect(page).to have_no_content("Image/photo")
      end
    end
  end

  it "uploads attachments", :slow do
    uncheck "proposal_has_no_image"
    fill_proposal(attach: true, extra_fields: false, skip_address: true)

    expect(page).to have_content(proposal_title)
    expect(page).to have_button("Images")
    expect(page).to have_button("Documents")
  end
end

shared_examples "creates reporting proposal" do
  it "redirects to the publish step" do
    fill_proposal(skip_group: true)

    expect(page).to have_content(proposal_title)
    expect(page).to have_content(user.name)
    expect(page).to have_content(proposal_body)
    expect(page).to have_content(translated(proposal_category.name))

    expect(page).to have_button("Publish")

    expect(page).to have_css("a", text: "Modify the proposal")
  end

  it "publishes the reporting proposal" do
    fill_proposal

    click_on "Publish"

    expect(page).to have_content("successfully published")

    expect(page).to have_content(proposal_title)
    body = translated(proposal.body)
    expect(body).to have_content(proposal_body)
    expect(proposal.category).to eq(category)
    expect(proposal.address).to eq(address)
    expect(proposal.latitude).to eq(latitude)
    expect(proposal.longitude).to eq(longitude)
    expect(body).to have_content("HashtagAuto1")
    expect(body).to have_content("HashtagAuto2")
    expect(body).to have_content("HashtagSuggested1")
    expect(body).to have_no_content("HashtagSuggested2")
    expect(proposal.identities.first).to eq(user_group)
    expect(proposal.scope).to eq(scope)
  end

  it "modifies the proposal" do
    fill_proposal

    expect(page).to have_no_content("Images")
    expect(page).to have_no_content("Documents")

    click_on "Modify the proposal"
    find_by_id("proposal_has_no_image").click

    within ".wizard-steps" do
      expect(page).to have_content("Create your proposal")
      expect(page).to have_content("Compare")
      expect(page).to have_content("Publish your proposal")
    end

    expect(page).to have_content("Edit proposal draft")

    expect(page).to have_content("Images")
    expect(page).to have_content("Documents")

    click_on "Publish"

    expect(page).to have_content(proposal_title)
    expect(translated(proposal.body)).to have_content(proposal_body)
    expect(proposal.category).to eq(another_category)
  end

  it "remember has_no_address and has_no_image" do
    fill_proposal(skip_address: true, attach: false)

    click_on "Modify the proposal"

    expect(page).to have_css(".user-device-location button[disabled]")
    expect(page).to have_css("#proposal_add_photos_button[disabled]")
  end

  it "stores no address if checked" do
    fill_proposal(skip_address: true, skip_group: true, skip_scope: true)

    click_on "Publish"

    expect(page).to have_content("successfully published")

    expect(page).to have_content(proposal_title)
    expect(translated(proposal.body)).to have_content(proposal_body)
    expect(proposal.category).to eq(category)
    expect(proposal.identities.first).to eq(user)
    expect(proposal.scope).to be_nil
    expect(proposal.address).to be_nil
    expect(proposal.latitude).to be_nil
    expect(proposal.longitude).to be_nil
  end
end

shared_examples "maintains errors" do
  it "has errors in standard fields" do
    expect(page).to have_unchecked_field("proposal_has_no_address")

    check "proposal_has_no_address"
    fill_in :proposal_title, with: ""

    click_on "Send"

    expect(page).to have_checked_field("proposal_has_no_address")
    within "label[for=proposal_title]" do
      expect(page).to have_content("There is an error in this field")
    end
  end

  it "has errors in address field" do
    uncheck "proposal_has_no_address"
    fill_in :proposal_address, with: ""
    click_on "Send"

    expect(page).to have_unchecked_field("proposal_has_no_address")
    expect(page).to have_css("label[for=proposal_address].is-invalid-label")
  end

  it "has errors in photo address field" do
    expect(page).to have_no_css("label[for=proposal_add_photos].is-invalid-label")

    uncheck "proposal_has_no_image"

    click_on "Send"
    expect(page).to have_css("label[for=proposal_add_photos].is-invalid-label")
  end
end

shared_examples "normal form" do
  it "does not have modified fields" do
    expect(page).to have_no_field("proposal_has_no_address")
    expect(page).to have_no_field("proposal_has_no_image")
  end
end

shared_examples "creates normal proposal" do
  it "redirects to the publish step" do
    fill_proposal(extra_fields: false)

    within "#content" do
      expect(page).to have_content("Publish your proposal")
    end

    expect(page).to have_css(".edit_proposal")
  end

  it "publishes the proposal" do
    fill_proposal(extra_fields: false)
    expect(proposal.identities.first).to eq(user)

    click_on "Publish"

    expect(page).to have_content(proposal_title)
    expect(translated(proposal.body)).to eq(proposal_body)
    expect(proposal.category).to eq(another_category)
    expect(proposal.identities.first).to eq(user_group)
  end
end

shared_examples "remove errors" do |continue|
  it "remove errors when has_no_address is checked" do
    fill_in :proposal_address, with: ""
    if continue
      click_on "Continue"
    else
      click_on "Send"
    end

    expect(page).to have_css("label[for=proposal_address].is-invalid-label")

    check "proposal_has_no_address"

    expect(page).to have_no_css("label[for=proposal_address].is-invalid-label")
  end
end

shared_examples "prevents post if etiquette errors" do
  context "when title caps error" do
    let(:proposal_title) { "i do not start with caps" }

    it "shows errors" do
      fill_proposal

      within ".new_proposal" do
        expect(page).to have_no_content("Publish")
        expect(page).to have_content("must start with a capital letter")

        fill_in :proposal_title, with: "I start with caps"
        find("*[type=submit]").click
      end

      click_on "Publish"
      expect(page).to have_content("successfully published")
    end
  end

  context "when body caps error" do
    let(:proposal_body) { "i do not start with caps" }

    it "shows errors" do
      fill_proposal

      within ".new_proposal" do
        expect(page).to have_no_content("Publish")
        expect(page).to have_content("must start with a capital letter")

        fill_in :proposal_body, with: "I start with caps"
        find("*[type=submit]").click
      end

      click_on "Publish"
      expect(page).to have_content("successfully published")
    end
  end

  context "when body length error" do
    let(:proposal_body) { "I am short" }

    it "shows errors" do
      fill_proposal

      within ".new_proposal" do
        expect(page).to have_no_content("Publish")
        expect(page).to have_content("There is an error in this field")

        fill_in :proposal_body, with: "I am long enough to meet the requirements"
        find("*[type=submit]").click
      end

      click_on "Publish"
      expect(page).to have_content("successfully published")
    end
  end
end
