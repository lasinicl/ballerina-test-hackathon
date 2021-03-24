import ballerina/io;
import ballerina/log;
import ballerina/mime;

# This method is used to check media type of an attachment
#
# + contentType - Content type
# + return - Returns string with media type 
public function checkFileType(string contentType) returns string {
    var result = mime:getMediaType(contentType);
    if result is mime:MediaType {
        string baseType = result.getBaseType();
        if (mime:APPLICATION_XML == baseType || mime:TEXT_XML == baseType) {
            return ".xml";
        } else if (mime:APPLICATION_JSON == baseType) {
            return ".json";
        } else if (mime:TEXT_PLAIN == baseType) {
            return ".txt";
        } else if (mime:APPLICATION_PDF == baseType) {
            return ".pdf";
        }
    } else {
        log:printError("Unable to find file type: ", 'error = result);
    }
    return "";
}

# This method is used to write attachment to a file
#
# + attachment - Attachment  
# + filePath - File Path  
public function writeEntityToFile(mime:Entity attachment, string filePath) {
    var payload = attachment.getByteStream();
    if payload is stream<byte[], io:Error> {
        io:Error? result = io:fileWriteBlocksFromStream(filePath, payload);
        if (result is error) {
            log:printError("Error occurred while writing: ", 'error = result);
        }
        var cls = payload.close();
        if (cls is error) {
            log:printError("Error occurred while closing the stream: ", 'error = cls);
        }
    } else {
        log:printError("Error in parsing byte channel: ", 'error = payload);
    }
}
