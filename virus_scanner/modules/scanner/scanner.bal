import ballerina/file;
import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/regex;
import virus_scanner.commons;

http:Client scanClient = check new ("https://api.cloudmersive.com/virus/scan/file");

# This method is used to scan and save the safe attachments 
#
# + filesDirAbsPath - Absolute path to files directory 
# + attachment - Attachment  
# + count - Attchment count  
public function scanAndSaveSafeAttachments(string filesDirAbsPath, mime:Entity attachment, string count) {
    string fileType = commons:checkFileType(attachment.getContentType());
    if fileType != "" {
        string filePath = filesDirAbsPath + "/attachment" + count + fileType;
        commons:writeEntityToFile(attachment, filePath);
        http:Request req = new;
        req.setHeader("Apikey", "abcd");
        boolean isClean = scanForVirus(req, filePath);
        if !isClean {
            error? removeResults = file:remove(filesDirAbsPath);
        }
    }
}

# This method is used to scan the attachment for viruses
#
# + filePath - Path to file  
# + req - HTTP request
# + return - Returns whether the attachment is clean or not  
function scanForVirus(http:Request req, string filePath) returns boolean {
    req.setTextPayload("inputFile=" + filePath);
    var response = scanClient->post("", req);
    if (response is http:Response) {
        json|error jsonPayload = response.getJsonPayload();
        if (jsonPayload is json) {
            string pyld = jsonPayload.toJsonString();
            string cleanResult = regex:split(pyld, ",")[0];
            string cleanResultValue = regex:split(cleanResult, ":")[1];
            anydata|error isClean = cleanResultValue.fromBalString();
            if (isClean is boolean && isClean) {
                log:printInfo("Attachment is clean!");
                return isClean;
            } else {
                log:printWarn("Virus found in attachment!");
            }
        }
    } else {
        log:printError("Error occured in sending response: ", 'error = response);
    }
    return false;
}
