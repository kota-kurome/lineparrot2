class LinebotController < ApplicationController
#オウム返しをする用のコントローラー
    require 'line/bot'

    protect_from_forgery :except => [:callback]

    def client
        @client ||= Line::Bot::Client.new { |config|
        #環境変数からLINE_CHANNEL_SECRET、LINE_CHANNEL_TOKENをセット
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end

    def reply_content(event, messages)
      res = client.reply_message(
        event['replyToken'],
        messages
      )
      logger.warn res.read_body unless Net::HTTPOK === res
      res
    end

    def callback
        body = request.body.read

        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
          error 400 do 'Bad Request' end
        end

        events = client.parse_events_from(body)
    
        events.each do |event|
          case event
          when Line::Bot::Event::Message
            case event.type
            when Line::Bot::Event::MessageType::Text
              if(rand(1)==0)
                reply_content(event,{
                  type: "template",
                  altText: "this is a confirm template",
                  template: {
                      type: "confirm",
                      text: "あとさきかんがえずにしゃべってしまうほう？",
                      actions: [
                          {
                            type: "message",
                            label: "はい",
                            text: "君はうっかりや"
                          },
                          {
                            type: "message",
                            label: "いいえ",
                            text: "君はがんばりや"
                          }
                    ]
                  }
                })
              else
                reply_content(event,{
                  type: "template",
                  altText: "this is a confirm template",
                  template: {
                      type: "confirm",
                      text: "いつもみんなより一歩先を歩いていたい？",
                      actions: [
                          {
                            type: "message",
                            label: "はい",
                            text: "君はなまいき"
                          },
                          {
                            type: "message",
                            label: "いいえ",
                            text: "君はおだやか"
                          }
                      ]
                  }
                })
              end

=begin
              message = {
                type: 'text',
                text: event.message['text']
              }
=end
            end
          end
          #client.reply_message(event['replyToken'], message)
        end
        head :ok
    end
end
