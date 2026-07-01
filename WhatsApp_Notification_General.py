from twilio.rest import Client

def send_whatsapp():
    # Twilio credentials
    account_sid = 'AC5b155bd57564309f05c59d6d5da8251f'  # Replace with your Twilio Account SID
    auth_token = '0cc25ba60b51bab9740a3eccc4c9bcfb'    # Replace with your Twilio Auth Token
    twilio_whatsapp_number = 'whatsapp:+14155238886'  # Twilio sandbox number for WhatsApp

    # Recipient's WhatsApp number
    to_whatsapp_number = 'whatsapp:+918766486458'  # Replace with your WhatsApp number

    # Message content
    message_body = (
        "[192.168.17.41]: Boss! Your Process is Finally Done 🎉\n\n"
        "\n\n"
        "❤️ -- Yours, Kivi"
    )

    # Twilio client setup
    client = Client(account_sid, auth_token)

    # Send WhatsApp message
    message = client.messages.create(
        body=message_body,
        from_=twilio_whatsapp_number,
        to=to_whatsapp_number
    )
    print(f"WhatsApp message sent with SID: {message.sid}")

if __name__ == "__main__":
    send_whatsapp()
