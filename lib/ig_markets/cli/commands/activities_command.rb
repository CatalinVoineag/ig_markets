module IGMarkets
  module CLI
    # Implements the `ig_markets activities` command.
    class Main
      desc 'activities', 'Prints account activities'

      option :days, type: :numeric, required: true, desc: 'The number of days to print account activities for'
      option :start_date, desc: 'The start date to print account activities from, format: yyyy-mm-dd'

      def activities
        self.class.begin_session(options) do |_dealing_platform|
          activities = gather_account_history(:activities).sort_by(&:date)

          table = ActivitiesTable.new activities

          puts table
        end
      end

      private

      def gather_account_history(method_name)
        history_options = if options[:start_date]
                            from = Date.strptime options[:start_date], '%F'
                            to = from + options[:days].to_i

                            { from: from, to: to }
                          else
                            { days: options[:days] }
                          end

        Main.dealing_platform.account.send method_name, history_options
      end
    end
  end
end
