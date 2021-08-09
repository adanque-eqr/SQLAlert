//Author: 	Alan Danque
//Date:		20190905
//Purpose:	CSMail / SQLAlert
using System;
using System.Net.Mail;
using System.Data;
using System.Data.SqlClient;

class SQLAlert
{

    static void Main(string[] args)
    {

        String ToEmailAddress;
        String CCEmailAddress;
        String BCCEmailAddress;
        String FromEmailAddress;
        String EmailSubject;
        String EmailMsgID;
        String EmailAttachment;
        Char delims;
        String ContentType;
        int ContentTypeInt;
        String ContentTypeUse = "";
        String AliasFromName = "";
        String SQLServerName = "";
        String MailPriority = "";
		String EmailDBName = "";

        delims = Convert.ToChar(";");
        if (args.Length == 0)
        {
            Console.WriteLine("No arguments were given. Please verify command issued.");
        }
        else
        {
            foreach (String a in args)
            {
                Console.WriteLine(a);
            }
        }

        // Passed Arguments
        ToEmailAddress = (args[0]);
        CCEmailAddress = (args[1]);
        BCCEmailAddress = (args[2]);
        FromEmailAddress = (args[3]);
        EmailSubject = (args[4]);
        EmailMsgID = (args[5]);
        EmailAttachment = (args[6]);
        ContentType = (args[7]);
        AliasFromName = (args[8]);
        SQLServerName = (args[9]);
		EmailDBName = (args[10]);
        //	MailPriority = (args[10]); new feature not to be released at this time. ATD


        // Parse Email Content Type.
        int number;
        bool success = Int32.TryParse(ContentType, out number);
        if (success)
        {
            Console.WriteLine("Converted '{0}' to {1}.", ContentType, number);
        }
        else
        {
            Console.WriteLine("Attempted conversion of '{0}' failed. Verify the EID passed",
                               ContentType ?? "<null>");
        }

        ContentTypeInt = number;

        switch (ContentTypeInt)
        {
            case 1:
                ContentTypeUse = "TEXT";
                break;
            case 2:
                ContentTypeUse = "HTML";
                break;
            case 3:
                ContentTypeUse = "text/plain";
                break;
            case 4:
                ContentTypeUse = "text/html";
                break;
        }


        //string ContentTypeUseValue = ContentTypeUse + "; charset=UTF-8";
        //string ContentTypeUseValue = ContentTypeUse + "; charset=UTF-16";
        string ContentTypeUseValue = ContentTypeUse + "; charset=us-ascii";
        Console.WriteLine("Arguments ");
        Console.WriteLine(ToEmailAddress);
        Console.WriteLine(CCEmailAddress);
        Console.WriteLine(BCCEmailAddress);
        Console.WriteLine(FromEmailAddress);
        Console.WriteLine(EmailSubject);
        Console.WriteLine(EmailMsgID);
        Console.WriteLine(EmailAttachment);
        Console.WriteLine(ContentType);
        Console.WriteLine(ContentTypeUse);
        Console.WriteLine(AliasFromName);
        Console.WriteLine(SQLServerName);
		Console.WriteLine(EmailDBName);


        // dbconnect to DB to get the message detail.
        string FullMessage = "";
        string connetionString = null;
        string query = "select replace(MESSAGE,char(13),'\r\n') MESSAGE from "+EmailDBName+"..ALERT_SESSION (NOLOCK) where EID = " + EmailMsgID;
        SqlConnection cnn;
        connetionString = "Data Source=" + SQLServerName + ";Initial Catalog="+EmailDBName+";Integrated Security=SSPI";

        cnn = new SqlConnection(connetionString);
        try
        {
            SqlCommand command = new SqlCommand(query, cnn);
            cnn.Open();
            Console.WriteLine("Connection to " + SQLServerName + " Successful!");

            SqlDataReader reader = command.ExecuteReader(CommandBehavior.CloseConnection);
            {
                while (reader.Read())
                {
                    FullMessage = FullMessage + reader["MESSAGE"].ToString();
                }
            }
            cnn.Close();
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex);
        }

        // Construct the email message
        MailMessage message = new MailMessage();
        message.From = new MailAddress(FromEmailAddress, AliasFromName);


        // Parse & pass recieved email addresses 
        int ToEmailAddresslen = ToEmailAddress.Length;
        int ToAddressVal = 0;
        if (ToEmailAddresslen > 0)
        {
            string[] ReciptokensTo = ToEmailAddress.Split(delims);
            int tokenCount = ReciptokensTo.Length;
            Console.WriteLine("tokenCount");
            Console.WriteLine(ReciptokensTo);
            Console.WriteLine(tokenCount);
            for (int jTo = 0; jTo < tokenCount; jTo++)
            {
                ToAddressVal = 0;
                ToAddressVal = ReciptokensTo[jTo].Replace(";", "").Length;
                if (ToAddressVal > 0)
                {
                    message.To.Add(ReciptokensTo[jTo].Replace(";", ""));
                }
            }
        }

        int CCEmailAddresslen = CCEmailAddress.Length;
        int CCEmailAddressVal = 0;
        if (CCEmailAddresslen > 0)
        {
            String[] ReciptokensCC = CCEmailAddress.Split(delims);
            int tokenCountCC = ReciptokensCC.Length;
            for (int jCC = 0; jCC < tokenCountCC; jCC++)
            {
                CCEmailAddressVal = 0;
                CCEmailAddressVal = ReciptokensCC[jCC].Replace(";", "").Length;
                if (CCEmailAddressVal > 0)
                {
                    message.CC.Add(ReciptokensCC[jCC].Replace(";", ""));
                }

            }
        }

        int BCCEmailAddresslen = BCCEmailAddress.Length;
        int BCCEmailAddressVal = 0;
        if (BCCEmailAddresslen > 0)
        {
            String[] ReciptokensBCC = BCCEmailAddress.Split(delims);
            int tokenCountBCC = ReciptokensBCC.Length;
            for (int jBCC = 0; jBCC < tokenCountBCC; jBCC++)
            {
                BCCEmailAddressVal = 0;
                BCCEmailAddressVal = ReciptokensBCC[jBCC].Replace(";", "").Length;
                if (BCCEmailAddressVal > 0)
                {
                    message.Bcc.Add(ReciptokensBCC[jBCC].Replace(";", ""));
                }
            }
        }

        Console.WriteLine("THIS IS THE FULLMESSAGE");
        Console.WriteLine(FullMessage);
        message.Subject = EmailSubject;
        //message.BodyEncoding = System.Text.Encoding.UTF32;
        //message.BodyEncoding = System.Text.Encoding.UTF8;
        message.BodyEncoding = System.Text.Encoding.ASCII;
        //message.BodyEncoding = System.Text.Encoding.Unicode;
        //message.BodyEncoding = System.Text.Encoding.Default;
        message.Body = FullMessage;
        //message.BodyFormat = MailFormat.Html;
        //message.BodyEncoding =  System.Text.Encoding.UTF8;


        string hostName = "";
        string mserver = "eqrsmtp01";
        bool Host1 = string.IsNullOrEmpty(SQLServerName);
        if (Host1)
        {
            hostName = System.Net.Dns.GetHostName();
        }
        else
        {
            hostName = SQLServerName;
        }

        string userName = System.Security.Principal.WindowsIdentity.GetCurrent().Name.Substring(System.Security.Principal.WindowsIdentity.GetCurrent().Name.IndexOf(@"\") + 1);
        string UniqString = "2000000.11111111111111."; // Need to review if needed.
        string headermsgtoadd = UniqString + "SQLAlert." + userName + "@" + hostName;

        // Header work 
        message.Headers.Add("message-id", headermsgtoadd);

        bool AttachFile = string.IsNullOrEmpty(EmailAttachment);
        if (AttachFile != true)
        {
            //Attachment attch = new System.Net.Mail.Attachment(EmailAttachment);

            // NEW CODE ATD 20200423
            int EmailAttachmentlen = EmailAttachment.Length;
            int EmailAttachmentVal = 0;
            if (EmailAttachmentlen > 0)
            {
                String[] ReciptokensEmailAttachment = EmailAttachment.Split(delims);
                int tokenCountEmailAttachment = ReciptokensEmailAttachment.Length;
                for (int jAttchmnts = 0; jAttchmnts < tokenCountEmailAttachment; jAttchmnts++)
                {
                    EmailAttachmentVal = 0;
                    EmailAttachmentVal = ReciptokensEmailAttachment[jAttchmnts].Replace(";", "").Length;
                    if (EmailAttachmentVal > 0)
                    {
                        //message.Attachments.Add(attch);
                        //message.Bcc.Add(ReciptokensBCC[jBCC].Replace(";", ""));
                        Attachment attch = new System.Net.Mail.Attachment(ReciptokensEmailAttachment[jAttchmnts].Replace(";", ""));
                        message.Attachments.Add(attch);
                    }
                }
            }
        }


        //bool AttachFile = string.IsNullOrEmpty(EmailAttachment);
        //if (AttachFile != true)
        //{
        //    Attachment attch = new System.Net.Mail.Attachment(EmailAttachment);
        //     message.Attachments.Add(attch);
        //}



        // Parse Priority - if not normal then High.
        bool MsgPriority = string.IsNullOrEmpty(MailPriority);
        if (MsgPriority != true)
        {
            message.Priority = System.Net.Mail.MailPriority.High;
        }

        // Print Headers
        string[] keys = message.Headers.AllKeys;
        Console.WriteLine("Headers");
        foreach (string s in keys)
        {
            Console.WriteLine("{0}:", s);
            Console.WriteLine("    {0}", message.Headers[s]);
        }


        // Contenttype work
        AlternateView plainTextView = AlternateView.CreateAlternateViewFromString(message.Body.Trim(), new System.Net.Mime.ContentType(ContentTypeUseValue));
        plainTextView.TransferEncoding = System.Net.Mime.TransferEncoding.QuotedPrintable;
        message.AlternateViews.Add(plainTextView);

        SmtpClient client = new SmtpClient(mserver);
        client.UseDefaultCredentials = false;
        try
        {
            client.Send(message);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Exception caught in CreateTestMessage2(): {0}",
                        ex.ToString());
        }
        finally
        {
            Console.WriteLine("Sent message successfully....");
        }



    }
}