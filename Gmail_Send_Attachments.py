import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import os
import argparse

def send_email_with_attachments(file_paths, subject, body, closing_remark, recipients):
    fromaddr = 'omyashete414@gmail.com'  # Replace with your Gmail email address

    # Create a multipart message
    msg = MIMEMultipart()
    msg['From'] = fromaddr
    msg['To'] = ", ".join(recipients)
    msg['Subject'] = subject

    # Attach the text body to the email
    full_body = f"{body}\n\n{closing_remark}"
    msg.attach(MIMEText(full_body.encode('utf-8'), 'plain', 'utf-8'))

    # Attach each file in file_paths
    for file_path in file_paths:
        if os.path.isfile(file_path):  # Check if file exists
            part = MIMEBase('application', 'octet-stream')
            with open(file_path, 'rb') as file:
                part.set_payload(file.read())
            encoders.encode_base64(part)
            part.add_header('Content-Disposition', f'attachment; filename={os.path.basename(file_path)}')
            msg.attach(part)
        else:
            print(f"File not found: {file_path}")

    # Gmail authentication details
    username = 'omyashete414@gmail.com'   # Replace with your Gmail email address
    password = 'abcd'         # Replace with the App Password generated for your Gmail account

    # Send the email
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(username, password)
        server.sendmail(fromaddr, recipients, msg.as_string())
        server.quit()
        print("Email sent successfully.")
    except Exception as e:
        print(f"Failed to send email. Error: {e}")

def main():
    # Setting up argument parsing
    parser = argparse.ArgumentParser(
        description="Send an email with attachments. You can specify a folder to attach all files or a specific file."
    )
    parser.add_argument(
        '-p', '--path', type=str, required=True,
        help="Path of the folder containing files or a single file to attach."
    )
    parser.add_argument(
        '-r', '--recipients', type=str, required=True,
        help="Recipient email addresses, separated by commas."
    )
    parser.add_argument(
        '-s', '--subject', type=str, required=True,
        help="Subject of the email."
    )
    parser.add_argument(
        '-b', '--body', type=str, required=True,
        help="Body of the email."
    )
    parser.add_argument(
        '-c', '--closing', type=str, required=True,
        help="Closing remarks for the email (e.g., 'Regards, Omprakash')."
    )

    # Parse the arguments
    args = parser.parse_args()

    # Process the file path
    file_or_folder_path = args.path.strip()

    # Determine if it's a folder or a single file
    files_to_send = []  # Initialize the list for files to send
    if os.path.isdir(file_or_folder_path):
        # If it's a directory, get all files in the folder
        files_to_send = [os.path.join(file_or_folder_path, f) for f in os.listdir(file_or_folder_path)]
    elif os.path.isfile(file_or_folder_path):
        # If it's a file, add the single file to the list
        files_to_send = [file_or_folder_path]
    else:
        print("The provided path is neither a valid file nor a directory.")
        exit()

    # Get the recipients
    recipients = [email.strip() for email in args.recipients.split(",")]

    # Send the email with the specified attachments
    send_email_with_attachments(files_to_send, args.subject, args.body, args.closing, recipients)

if __name__ == "__main__":
    main()
