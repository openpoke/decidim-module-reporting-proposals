# frozen_string_literal: true

module Decidim
  # This namespace holds the logic of the `decidim-reporting_proposals` module.
  module ReportingProposals
    include ActiveSupport::Configurable

    # Public Setting that defines after how many days a not-answered proposal is overdue
    # Set it to 0 (zero) if you don't want to use this feature
    config_accessor :unanswered_proposals_overdue do
      7
    end

    # Public Setting that defines after how many days an evaluating-state proposal is overdue
    # Set it to 0 (zero) if you don't want to use this feature
    config_accessor :evaluating_proposals_overdue do
      3
    end

    # Public Setting that defines whether the administrator is allowed to hide the proposals.
    # Set to false if you do not want to use this feature
    config_accessor :allow_admins_to_hide_proposals do
      true
    end

    # Public Setting that allows to configure which component will have "Use my location" button
    # in a geocoded address field. Accepts an array of component manifest names
    config_accessor :show_my_location_button do
      [:proposals, :meetings, :reporting_proposals]
    end

    # Public Setting that adds a button next to the "add image" input[type=file] to open the camera directly
    config_accessor :use_camera_button do
      [:proposals, :reporting_proposals]
    end

    # Public Setting to prevent adding the camera button on not photo/image input[type=file]
    config_accessor :camera_button_on_attachments do
      false
    end

    # Public setting to prevent valuators or admins to modify the photos attached to a proposal
    # otherwise can be configured at the component level
    config_accessor :allow_proposal_photo_editing do
      true
    end

    # Public setting to allow to assign other valuators
    config_accessor :valuators_assign_other_valuators do
      true
    end

    # Public setting to to get an e-mail notification when there is a new answer to a proposal
    config_accessor :notify_authors_on_publish do
      [:proposals, :reporting_proposals]
    end
  end
end
