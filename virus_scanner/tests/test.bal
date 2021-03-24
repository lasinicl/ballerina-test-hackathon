import ballerina/email;
import ballerina/log;
import ballerina/mime;
import ballerina/test;

@test:Config {enable: true}
function testSendEmail() returns error? {
    email:SmtpClient smtpClient = check new ("smtp.gmail.com", "yyy@gmail.com", "yyy");
    email:Attachment att = {
        filePath: "/home/lasini/aaa.pdf",
        contentType: mime:APPLICATION_PDF
    };
    email:Message email = {
        to: ["xxx@gmail.com"],
        subject: "Sample Email",
        body: "This is a sample email.",
        'from: "yyy@gmail.com",
        sender: "yyy@gmail.com",
        attachments: att
    };

    email:Error? sentMail = check smtpClient->sendMessage(email);
    if sentMail is email:Error {
        log:printError("Error occured when sending email: ", 'error = sentMail);
    } else {
        log:printInfo("Email sent successfully!");
    }
}

@test:Config {}
function testRecieveEmail() returns error? {
    email:PopConfiguration popConfig = {port: 995};

    email:PopClient popClient = check new ("smtp.gmail.com", "xxx@gmail.com", "xxx", popConfig);

    email:Message? emailResponse = check popClient->receiveMessage();
    if emailResponse is email:Message {
        log:printInfo("Unread email recieved!");
    } else {
        log:printInfo("There are no unread emails in the INBOX.");
    }
}
