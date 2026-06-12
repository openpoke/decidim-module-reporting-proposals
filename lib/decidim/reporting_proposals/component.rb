# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/meetings"

Decidim.register_component(:reporting_proposals) do |component|
  # reuses the same public/admin controllers as proposals, custom engines from this module are used for custom actions
  component.engine = Decidim::Proposals::Engine
  component.admin_engine = Decidim::Proposals::AdminEngine
  component.stylesheet = "decidim/proposals/proposals"
  component.icon = "media/images/decidim_proposals.svg"

  component.on(:before_destroy) do |instance|
    raise "Can't destroy this component when there are proposals" if Decidim::Proposals::Proposal.where(component: instance).any?
  end

  component.on(:create) do |instance|
    admin_user = GlobalID::Locator.locate(instance.versions.first.whodunnit)
    Decidim::Proposals.create_default_states!(instance, admin_user)
  end

  component.data_portable_entities = ["Decidim::Proposals::Proposal"]

  component.newsletter_participant_entities = ["Decidim::Proposals::Proposal"]

  component.actions = %w(endorse vote create withdraw amend comment vote_comment)

  component.query_type = "Decidim::ReportingProposals::ReportingProposalsType"

  component.permissions_class_name = "Decidim::Proposals::Permissions"

  REP_POSSIBLE_SORT_ORDERS = %w(default random recent most_endorsed most_voted most_commented most_followed with_more_authors).freeze

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
    settings.attribute :vote_limit, type: :integer, default: 0
    settings.attribute :minimum_votes_per_user, type: :integer, default: 0
    settings.attribute :proposal_limit, type: :integer, default: 0
    settings.attribute :proposal_length, type: :integer, default: 500
    settings.attribute :proposal_edit_time, type: :enum, default: "limited", choices: %w(limited infinite)
    settings.attribute :edit_time, type: :integer_with_units, default: [5, "minutes"], required: true, units: %w(minutes hours days)
    settings.attribute :proposal_edit_before_minutes, type: :integer, default: 5
    settings.attribute :threshold_per_proposal, type: :integer, default: 0
    settings.attribute :can_accumulate_votes_beyond_threshold, type: :boolean, default: false
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :default_sort_order, type: :select, default: "default", choices: REP_POSSIBLE_SORT_ORDERS
    settings.attribute :official_proposals_enabled, type: :boolean, default: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: false
    settings.attribute :geocoding_enabled, type: :boolean, default: true
    settings.attribute :geocoding_comparison_enabled, type: :boolean, default: true
    settings.attribute :geocoding_comparison_radius, type: :integer, default: 30
    settings.attribute :geocoding_comparison_newer_than, type: :integer, default: 60
    settings.attribute :attachments_allowed, type: :boolean, default: true
    settings.attribute :only_photo_attachments, type: :boolean, default: true
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
    settings.attribute :collaborative_drafts_enabled, type: :boolean, default: false, readonly: ->(_) { true }
    settings.attribute :participatory_texts_enabled, type: :boolean, default: false, readonly: ->(_) { true }
    settings.attribute :amendments_enabled, type: :boolean, default: false
    settings.attribute :amendments_wizard_help_text, type: :text, translated: true, editor: true, required: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :new_proposal_body_template, type: :text, translated: true, editor: true, required: false
    settings.attribute :new_proposal_help_text, type: :text, translated: true, editor: true
    settings.attribute :proposal_wizard_step_1_help_text, type: :text, translated: true, editor: true
    settings.attribute :proposal_wizard_step_2_help_text, type: :text, translated: true, editor: true
    settings.attribute :proposal_wizard_step_3_help_text, type: :text, translated: true, editor: true, readonly: ->(_) { true }
    settings.attribute :proposal_wizard_step_4_help_text, type: :text, translated: true, editor: true
    settings.attribute :unanswered_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.unanswered_proposals_overdue
    settings.attribute :evaluating_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.evaluating_proposals_overdue
    settings.attribute :proposal_photo_editing_enabled, type: :boolean, default: true
    settings.attribute :additional_buttons_show, type: :boolean, default: false
    settings.attribute :additional_button_text, type: :string, translated: true, editor: true
    settings.attribute :additional_button_link, type: :string, editor: true
    settings.attribute :additional_buttons_for_show_proposal_show, type: :boolean, default: false
    settings.attribute :additional_button_for_show_proposal_text, type: :string, translated: true, editor: true
    settings.attribute :additional_button_for_show_proposal_link, type: :string, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :likes_enabled, type: :boolean, default: true
    settings.attribute :likes_blocked, type: :boolean, default: false
    settings.attribute :votes_enabled, type: :boolean, default: false
    settings.attribute :votes_blocked, type: :boolean, default: false
    settings.attribute :votes_hidden, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :creation_enabled, type: :boolean, default: true
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :publish_answers_immediately, type: :boolean, default: true
    settings.attribute :answers_with_costs, type: :boolean, default: false
    settings.attribute :default_sort_order, type: :select, include_blank: true, choices: REP_POSSIBLE_SORT_ORDERS
    settings.attribute :amendment_creation_enabled, type: :boolean, default: true
    settings.attribute :amendment_reaction_enabled, type: :boolean, default: true
    settings.attribute :amendment_promotion_enabled, type: :boolean, default: true
    settings.attribute :amendments_visibility, type: :enum, default: "all", choices: Decidim.config.amendments_visibility_options
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :automatic_hashtags, type: :text, editor: false, required: false
    settings.attribute :suggested_hashtags, type: :text, editor: false, required: false
  end

  component.register_resource(:collaborative_draft) do |resource|
    resource.model_class_name = "Decidim::Proposals::CollaborativeDraft"
    resource.card = "decidim/proposals/collaborative_draft"
    resource.reported_content_cell = "decidim/proposals/collaborative_drafts/reported_content"
  end

  component.register_stat :reporting_proposals_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(components, start_at, end_at, :reporting_proposals).published.not_withdrawn.not_hidden.count
  end

  component.register_stat :reporting_proposals_accepted, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(components, start_at, end_at, :reporting_proposals).accepted.not_hidden.count
  end

  component.register_stat :reporting_proposals_votes_count, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at, :reporting_proposals).published.not_hidden
    Decidim::Proposals::ProposalVote.where(proposal: proposals).count
  end

  component.register_stat :reporting_proposals_likes_count, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at, :reporting_proposals).not_hidden
    proposals.sum(:endorsements_count)
  end

  component.register_stat :reporting_proposals_comments_count, tag: :comments do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at, :reporting_proposals).published.not_hidden
    proposals.sum(:comments_count)
  end

  component.register_stat :reporting_proposals_followers_count, tag: :followers, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, start_at, end_at|
    proposals_ids = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at, :reporting_proposals).published.not_hidden.pluck(:id)
    Decidim::Follow.where(decidim_followable_type: "Decidim::Proposals::Proposal", decidim_followable_id: proposals_ids).count
  end

  component.exports :proposals do |exports|
    exports.collection do |component_instance, user|
      space = component_instance.participatory_space

      collection = Decidim::Proposals::Proposal
                   .published
                   .not_hidden
                   .where(component: component_instance)
                   .includes(:taxonomies, :component)

      if space.user_roles(:evaluator).where(user:).any?
        collection.with_valuation_assigned_to(user, space)
      else
        collection
      end
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Proposals::ProposalSerializer
  end

  component.exports :proposal_comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Proposals::Proposal, component_instance
      ).includes(:author, root_commentable: { component: { participatory_space: :organization } })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.imports :proposals do |imports|
    imports.form_view = "decidim/proposals/admin/imports/proposals_fields"
    imports.form_class_name = "Decidim::Proposals::Admin::ProposalsFileImportForm"

    imports.messages do |msg|
      msg.set(:resource_name) { |count: 1| I18n.t("decidim.proposals.admin.imports.resources.proposals", count:) }
      msg.set(:title) { I18n.t("decidim.proposals.admin.imports.title.proposals") }
      msg.set(:label) { I18n.t("decidim.proposals.admin.imports.label.proposals") }
      msg.set(:help) { I18n.t("decidim.proposals.admin.imports.help.proposals") }
    end

    imports.creator Decidim::Proposals::Import::ProposalCreator
  end

  component.imports :answers do |imports|
    imports.messages do |msg|
      msg.set(:resource_name) { |count: 1| I18n.t("decidim.proposals.admin.imports.resources.answers", count:) }
      msg.set(:title) { I18n.t("decidim.proposals.admin.imports.title.answers") }
      msg.set(:label) { I18n.t("decidim.proposals.admin.imports.label.answers") }
      msg.set(:help) { I18n.t("decidim.proposals.admin.imports.help.answers") }
    end

    imports.creator Decidim::Proposals::Import::ProposalAnswerCreator
    imports.example do |import_component|
      organization = import_component.organization
      [
        %w(id state) + organization.available_locales.map { |l| "answer/#{l}" },
        [1, "accepted"] + organization.available_locales.map { "Example answer" },
        [2, "rejected"] + organization.available_locales.map { "Example answer" },
        [3, "evaluating"] + organization.available_locales.map { "Example answer" }
      ]
    end
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    step_settings = if participatory_space.allows_steps?
                      { participatory_space.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true } }
                    else
                      {}
                    end

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :reporting_proposals).i18n_name,
      manifest_name: :reporting_proposals,
      published_at: Time.current,
      participatory_space:,
      settings: {
        vote_limit: 0,
        collaborative_drafts_enabled: true
      },
      step_settings:
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    Decidim::Proposals.create_default_states!(component, admin_user)

    5.times do |n|
      proposal_state, answer, state_published_at = random_state_answer
      proposal_state = Decidim::Proposals::ProposalState.where(component:, token: proposal_state).first

      params = {
        component:,
        title: { en: Faker::Lorem.sentence(word_count: 2) },
        body: { en: Faker::Lorem.paragraphs(number: 2).join("\n") },
        proposal_state:,
        answer:,
        answered_at: proposal_state.present? ? Time.current : nil,
        state_published_at:,
        published_at: Time.current
      }

      proposal = Decidim.traceability.perform_action!(
        "publish",
        Decidim::Proposals::Proposal,
        admin_user,
        visibility: "all"
      ) do
        proposal = Decidim::Proposals::Proposal.new(params)
        proposal.add_coauthor(participatory_space.organization)
        proposal.save!
        proposal
      end

      if n.positive?
        Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample(n).each do |author|
          proposal.add_coauthor(author)
        end
      end

      if proposal.state.nil?
        email = "amendment-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-amend#{n}@example.org"
        name = "#{Faker::Name.name} #{participatory_space.id} #{n} amend#{n}"

        author = Decidim::User.find_or_initialize_by(email:)
        author.update!(
          password: "decidim123456",
          password_confirmation: "decidim123456",
          name:,
          nickname: Faker::Twitter.unique.screen_name,
          organization: component.organization,
          tos_agreement: "1",
          confirmed_at: Time.current
        )

        params = {
          component:,
          title: { en: "#{proposal.title["en"]} #{Faker::Lorem.sentence(word_count: 1)}" },
          body: { en: "#{proposal.body["en"]} #{Faker::Lorem.sentence(word_count: 3)}" },
          proposal_state: Decidim::Proposals::ProposalState.where(component: proposal.component, token: :evaluating).first,
          answer: nil,
          answered_at: Time.current,
          published_at: Time.current
        }

        emendation = Decidim.traceability.perform_action!(
          "create",
          Decidim::Proposals::Proposal,
          author,
          visibility: "public-only"
        ) do
          emendation = Decidim::Proposals::Proposal.new(params)
          emendation.add_coauthor(author)
          emendation.save!
          emendation
        end

        Decidim::Amendment.create!(
          amender: author,
          amendable: proposal,
          emendation:,
          state: "evaluating"
        )
      end

      (n % 3).times do |m|
        email = "vote-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-#{m}@example.org"
        name = "#{Faker::Name.name} #{participatory_space.id} #{n} #{m}"

        author = Decidim::User.find_or_initialize_by(email:)
        author.update!(
          password: "decidim123456",
          password_confirmation: "decidim123456",
          name:,
          nickname: Faker::Twitter.unique.screen_name,
          organization: component.organization,
          tos_agreement: "1",
          confirmed_at: Time.current,
          personal_url: Faker::Internet.url,
          about: Faker::Lorem.paragraph(sentence_count: 2)
        )

        Decidim::Proposals::ProposalVote.create!(proposal:, author:) unless proposal.published_state? && proposal.rejected?
        Decidim::Proposals::ProposalVote.create!(proposal: emendation, author:) if emendation
      end

      unless proposal.published_state? && proposal.rejected?
        (n * 2).times do |index|
          email = "like-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-endr#{index}@example.org"
          name = "#{Faker::Name.name} #{participatory_space.id} #{n} endr#{index}"

          author = Decidim::User.find_or_initialize_by(email:)
          author.update!(
            password: "decidim123456",
            password_confirmation: "decidim123456",
            name:,
            nickname: Faker::Twitter.unique.screen_name,
            organization: component.organization,
            tos_agreement: "1",
            confirmed_at: Time.current
          )
          Decidim::Like.create!(resource: proposal, author:)
        end
      end

      (n % 3).times do
        author_admin = Decidim::User.where(organization: component.organization, admin: true).all.sample

        Decidim::Proposals::ProposalNote.create!(
          proposal:,
          author: author_admin,
          body: Faker::Lorem.paragraphs(number: 2).join("\n")
        )
      end

      Decidim::Comments::Seed.comments_for(proposal)

      #
      # Collaborative drafts
      #
      state = if n > 3
                "published"
              elsif n > 2
                "withdrawn"
              else
                "open"
              end
      author = Decidim::User.where(organization: component.organization).all.sample

      draft = Decidim.traceability.perform_action!("create", Decidim::Proposals::CollaborativeDraft, author) do
        draft = Decidim::Proposals::CollaborativeDraft.new(
          component:,
          title: Faker::Lorem.sentence(word_count: 2),
          body: Faker::Lorem.paragraphs(number: 2).join("\n"),
          state:,
          published_at: Time.current
        )
        draft.coauthorships.build(author: participatory_space.organization)
        draft.save!
        draft
      end

      case n
      when 2
        author2 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author2)
        author3 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author3)
        author4 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author4)
        author5 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author5)
        author6 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author6)
      when 3
        author2 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author2)
      end

      Decidim::Comments::Seed.comments_for(draft)
    end

    Decidim.traceability.update!(
      Decidim::Proposals::CollaborativeDraft.all.sample,
      Decidim::User.where(organization: component.organization).all.sample,
      component:,
      title: Faker::Lorem.sentence(word_count: 2),
      body: Faker::Lorem.paragraphs(number: 2).join("\n")
    )
  end

  def random_state_answer
    n = rand(5)

    if n > 3
      [:accepted, Decidim::Faker::Localized.sentence(word_count: 10), Time.current]
    elsif n > 2
      [:rejected, nil, Time.current]
    elsif n > 1
      [:evaluating, nil, Time.current]
    elsif n.positive?
      [:accepted, Decidim::Faker::Localized.sentence(word_count: 10), nil]
    else
      [:not_answered, nil, nil]
    end
  end
end
