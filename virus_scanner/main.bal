import ballerina/email;
import ballerina/file;
import ballerina/log;
import ballerina/mime;
import virus_scanner.scanner;

string currentDir = file:getCurrentDir();
string filesDirAbsPath = check file:getAbsolutePath(currentDir + "/files");

public function main() returns error? {
    error? sendEmailResult = sendEmail();

    email:PopConfiguration popConfig = {port: 995};

    email:PopClient popClient = check new ("smtp.gmail.com", "yyy@gmail.com", "yyy", popConfig);
    email:Message? emailResponse = check popClient->receiveMessage();

    if emailResponse is email:Message {
        log:printInfo("Unread email recieved!");
        log:printInfo("Email Subject: " + emailResponse.subject);
    } else {
        log:printInfo("There are no unread emails in the INBOX.");
    }

    var attachments = emailResponse?.attachments;
    int count = 0;

    if attachments is (mime:Entity|email:Attachment)[] {
        foreach var attachment in attachments {
            if attachment is mime:Entity {
                scanner:scanAndSaveSafeAttachments(filesDirAbsPath, attachment, count.toString());
                count += 1;
            }
        }
    } else if attachments is mime:Entity {
        scanner:scanAndSaveSafeAttachments(filesDirAbsPath, attachments, count.toString());
    } else {
        log:printInfo("Email does not contain any attachments!");
    }

    email:Error? closeStatus = popClient->close();
}

# Sends an email using Smtp Client
# + return - Return error   
function sendEmail() returns error? {
    email:SmtpClient smtpClient = check new ("smtp.gmail.com", "xxx@gmail.com", "xxx");
    email:Attachment att = {
        filePath: "/home/lasini/aaa.pdf",
        contentType: mime:APPLICATION_PDF
    };
    email:Message email = {
        to: ["yyy@gmail.com"],
        subject: "Sample Email",
        body: "This is a sample email.",
        'from: "xxx@gmail.com",
        sender: "xxx@gmail.comk",
        attachments: att
    };

    check smtpClient->sendMessage(email);
}
