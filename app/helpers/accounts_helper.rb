module AccountsHelper

  def status_logs_color(log)
   log.status.nil?
  case log.status.to_sym
        when :viewed
              raw 'label-plan'
        when :sent
              raw 'label-primary'
        when :request_code
              raw 'label-info'
        when :signed
              raw 'label-success'
        when :downloaded
              raw 'label-warning'
        end

  end

  def status_logs_icon(log)
    unless log.status.nil?
                        case log.status.to_sym
                          when :viewed
                             raw '<i class="fa fa-eye"></i>'
                          when :sent
                             raw '<i class="fa fa-paper-plane"></i>'
                          when :request_code
                            raw '<i class="fa fa-phone"></i>'
                          when :signed
                            raw '<i class="fa fa-pencil"></i>'
                          when :downloaded
                            raw '<i class="fa fa-download"></i>'
                        end
                      end
  end

    def status_logs_text(log)
    unless log.status.nil?
                        case log.status.to_sym
                          when :viewed
                             raw "#{t(:log_viewed)} #{log.signer.name}"
                          when :sent
                             raw "#{t(:log_sent)} #{log.signer.name}"
                          when :request_code
                            raw "#{t(:log_request_code)} #{log.signer.name}"
                          when :signed
                            raw "#{t(:log_signed)} #{log.signer.name}"
                          when :downloaded
                            raw "#{t(:log_downloaded)} #{log.signer.name}"
                        end
                      end
  end

  def number_of_contract_signed(account)
    account.contracts.where(status: Signme::Contract.statuses["signed"]).count
  end

end
