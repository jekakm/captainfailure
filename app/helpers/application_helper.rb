module ApplicationHelper
  class AlertSender
    def initialize(server, check_result)
      @server = server
      @check_result = check_result
      send
    end

    private

    def send
      text = "Failed ICMP check to #{@server.dns_name}" if @check_result.check.check_type == 'icmp'
      text = "Port #{@check_result.check.tcp_port} closed on #{@server.dns_name}" if @check_result.check.check_type == 'port_open'
      text = "Failed #{@check_result.check.http_protocol}://#{@check_result.check.http_vhost}#{@check_result.check.http_uri} for #{@check_result.check.http_code} HTTP code on #{@server.dns_name}" if @check_result.check.check_type == 'http_code'
      text = "Failed #{@check_result.check.http_protocol}://#{@check_result.check.http_vhost}#{@check_result.check.http_uri} for #{@check_result.check.http_code} HTTP code and keyword #{@check_result.check.http_keyword} on #{@server.dns_name}" if @check_result.check.check_type == 'http_keyword'
      @server.notifications.each do |notification|
        notification_fail_count = notification_fail_count(@server.id, notification.id)
        if @check_result.check.fail_count >= notification_fail_count
          if notification.notification_type == 'email'
            AlertMailer.send_alert(notification.value, @check_result.check.check_type, @server.dns_name, text).deliver_now
          elsif notification.notification_type == 'sms'
            send_sms(notification.value, text)
          end
        end
      end

    end

    def send_sms(number, text)
      require 'turbosms'
      setting = Setting.where(name: 'turbosms').first
      TurboSMS.default_options[:login]    = setting.user
      TurboSMS.default_options[:password] = setting.password
      TurboSMS.default_options[:sender]   = setting.name_in_sms
      if text.length > 159
        sms_text = ''
        159.times { |i| sms_text << text[i] }
      else
        sms_text = text
      end
      TurboSMS.send_sms(number, sms_text)
    end

    def notification_fail_count(server_id, notification_id)
      server_notification = ServerNotification.where(server_id: server_id, notification_id: notification_id).first
      server_notification.fail_to_notify_count
    end

  end

end
