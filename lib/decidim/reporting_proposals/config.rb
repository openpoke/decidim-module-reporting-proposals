# frozen_string_literal: true

module Decidim
  # This namespace holds the logic of the `decidim-reporting_proposals` module.
  module ReportingProposals
    class << self
      def config = self

      def configure
        yield self
      end
    end

    # Public Setting that defines after how many days a not-answered proposal is overdue
    # Set it to 0 (zero) if you don't want to use this feature
    mattr_accessor :unanswered_proposals_overdue, default: 7

    # Public Setting that defines after how many days an evaluating-state proposal is overdue
    # Set it to 0 (zero) if you don't want to use this feature
    mattr_accessor :evaluating_proposals_overdue, default: 3

    # Public Setting that defines whether the administrator is allowed to hide the proposals.
    # Set to false if you do not want to use this feature
    mattr_accessor :allow_admins_to_hide_proposals, default: true

    # Public Setting that allows to configure which component will have "Use my location" button
    # in a geocoded address field. Accepts an array of component manifest names
    mattr_accessor :show_my_location_button, default: [:proposals, :meetings, :reporting_proposals]

    # Public Setting that adds a button next to the "add image" input[type=file] to open the camera directly
    mattr_accessor :use_camera_button, default: [:proposals, :reporting_proposals]

    # Public setting to prevent evaluators or admins to modify the photos attached to a proposal
    # otherwise can be configured at the component level
    mattr_accessor :allow_proposal_photo_editing, default: true

    # Public setting to allow evaluators to assign other evaluators to the proposals assigned to them
    # (false is stricter than Decidim, which always allows it)
    mattr_accessor :evaluators_assign_other_evaluators, default: true

    # Public setting to get an e-mail notification when there is a new answer to a proposal
    mattr_accessor :notify_authors_on_answering, default: [:proposals, :reporting_proposals]

    # Public setting to get an e-mail notification when the proposal is published
    mattr_accessor :notify_authors_on_publish, default: [:proposals, :reporting_proposals]

    # Identity email of the bot user ("Automatic assignment") that authors automatic
    # evaluator assignments in the admin log. No mail is sent to it; it only needs to be unique.
    mattr_accessor :automation_user_email, default: "reporting-proposals-automation@example.org"

    # Public setting that shows the answering deadlines in the admin list of proposals
    # Accepts an array of component manifest names
    mattr_accessor :proposal_answering_follow_up, default: [:proposals, :reporting_proposals]

    def self.answering_follow_up?(component)
      proposal_answering_follow_up.include?(component&.manifest_name&.to_sym)
    end
  end
end
