# frozen_string_literal: true

shared_examples "map can be hidden" do
  it "checkbox hides the map" do
    fill_in :proposal_address, with: address
    within ".tribute-container" do
      page.find("li", match: :first).click
    end

    expect(page).to have_content("You can move the point on the map")

    check "proposal_has_no_address"
    expect(page).not_to have_content("You can move the point on the map")
  end
end

shared_examples "map can be shown" do
  it "checkbox shows the map" do
    fill_proposal(extra_fields: false)

    expect(page).not_to have_content("You can move the point on the map")
    check "proposal_has_address"
    fill_in :proposal_address, with: address
    within ".tribute-container" do
      page.find("li", match: :first).click
    end

    expect(page).to have_content("You can move the point on the map")
  end
end

shared_examples "3 steps" do
  it "sidebar does not have the complete step" do
    expect(page).to have_content("Step 1 of 3")
    within ".wizard__steps" do
      expect(page).not_to have_content("Complete")
    end
  end

  it "redirects to the publish step" do
    fill_proposal

    expect(page).to have_content(proposal_title)
    expect(page).to have_content(user.name)
    expect(page).to have_content(proposal_body)
    expect(page).to have_content(translated(proposal_category.name))

    expect(page).to have_selector("button", text: "Publish")

    expect(page).to have_selector("a", text: "Modify the proposal")
  end

  context "when draft exists" do
    let!(:proposal_draft) { create(:proposal, :draft, users: [user], component: component, title: proposal_title, body: proposal_body) }

    it "redirects to complete" do
      visit_component
      click_link "New proposal"

      expect(page).to have_content("EDIT PROPOSAL DRAFT")
      expect(page).to have_content("Step 1 of 3")
    end
  end

  context "when only_photo_attachments is enabled" do
    let(:only_photos) { true }

    it "does not show the attachments" do
      expect(page).not_to have_content("Add an attachment")
      expect(page).to have_content("Image/photo")
    end

    context "and attachment are not active" do
      let(:attachments) { false }

      it "does not show the attachments or photos" do
        expect(page).not_to have_content("Add an attachment")
        expect(page).not_to have_content("Image/photo")
      end
    end
  end

  it_behaves_like "map can be hidden"

  it "publishes the reporting proposal" do
    fill_proposal

    click_button "Publish"

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
    expect(body).not_to have_content("HashtagSuggested2")
    expect(proposal.identities.first).to eq(user_group)
    expect(proposal.scope).to eq(scope)
  end

  it "uploads attachments", :slow do
    fill_proposal(attach: true, extra_fields: false, skip_address: true)

    expect(page).to have_content(proposal_title)
    expect(page).to have_content("RELATED IMAGES")
    expect(page).to have_content("RELATED DOCUMENTS")
  end

  it "modifies the proposal" do
    fill_proposal

    expect(page).not_to have_content("RELATED IMAGES")
    expect(page).not_to have_content("RELATED DOCUMENTS")

    click_link "Modify the proposal"

    expect(page).to have_content("EDIT PROPOSAL DRAFT")

    complete_proposal(attach: true)

    expect(page).to have_content("RELATED IMAGES")
    expect(page).to have_content("RELATED DOCUMENTS")

    click_button "Publish"

    expect(page).to have_content(proposal_title)
    expect(translated(proposal.body)).to have_content(proposal_body)
    expect(proposal.category).to eq(another_category)
  end

  it "stores no address if checked" do
    fill_proposal(skip_address: true, skip_group: true, skip_scope: true)

    click_button "Publish"

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

shared_examples "4 steps" do
  it "sidebar has the complete step" do
    expect(page).to have_content("Step 1 of 4")
    within ".wizard__steps" do
      expect(page).to have_content("Complete")
    end
  end

  it_behaves_like "map can be shown"

  it "redirects to the complete step" do
    fill_proposal(extra_fields: false)

    within ".section-heading" do
      expect(page).to have_content("COMPLETE YOUR PROPOSAL")
    end

    expect(page).to have_css(".edit_proposal")
  end

  it "publishes the proposal" do
    fill_proposal(extra_fields: false)
    expect(proposal.identities.first).to eq(user)

    complete_proposal

    click_button "Publish"

    expect(page).to have_content(proposal_title)
    expect(translated(proposal.body)).to eq(proposal_body)
    expect(proposal.category).to eq(another_category)
    expect(proposal.identities.first).to eq(user_group)
  end
end
