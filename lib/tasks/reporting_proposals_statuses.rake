# frozen_string_literal: true

namespace :reporting_proposals do
  def create_default_states!(component)
    colors = Decidim::Proposals.proposal_states_colors

    locale = Decidim.default_locale
    default_states = {
      evaluating: {
        token: :evaluating,
        bg_color: colors[:orange][:background],
        text_color: colors[:orange][:foreground],
        announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_in_evaluation_reason", scope: "decidim.proposals.proposals.show") } },
        title: { locale => I18n.with_locale(locale) { I18n.t(:evaluating, scope: "decidim.proposals.answers") } }
      },
      accepted: {
        token: :accepted,
        bg_color: colors[:green][:background],
        text_color: colors[:green][:foreground],
        announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_accepted_reason", scope: "decidim.proposals.proposals.show") } },
        title: { locale => I18n.with_locale(locale) { I18n.t(:accepted, scope: "decidim.proposals.answers") } }
      },
      rejected: {
        token: :rejected,
        bg_color: colors[:red][:background],
        text_color: colors[:red][:foreground],
        announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_rejected_reason", scope: "decidim.proposals.proposals.show") } },
        title: { locale => I18n.with_locale(locale) { I18n.t(:rejected, scope: "decidim.proposals.answers") } }
      }
    }
    default_states.each_key do |key|
      default_states[key][:object] = Decidim::Proposals::ProposalState.find_or_create_by(component:, **default_states[key])
    end
    default_states.merge(not_answered: { token: :not_answered })
  end

  desc "Migrate statuses tables"
  task migrate_statuses: :environment do
    STATES = { 0 => :not_answered, 10 => :evaluating, 20 => :accepted, -10 => :rejected }.freeze
    Decidim::Component.where(manifest_name: "reporting_proposals").find_each do |component|
      puts "Creating default states for component ##{component.id} \"#{component.name.values.first}\""
      default_states = create_default_states!(component)

      Decidim::Proposals::Proposal.where(decidim_component_id: component.id).find_each do |proposal|
        next if proposal.old_state.zero?

        puts "Migrating proposal ##{proposal.id} from state #{proposal.old_state} (#{STATES[proposal.old_state]}) to #{default_states.dig(STATES[proposal.old_state], :token)}"
        proposal.update!(proposal_state: default_states.dig(STATES[proposal.old_state], :object))
      end
    end
  end
end
