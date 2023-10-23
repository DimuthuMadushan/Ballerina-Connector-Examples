import connector_examples.gdrive_remote_client as remote_client;
import connector_examples.gdrive_resource_client as resource_client;

import ballerina/http;
import ballerina/io;
import ballerinax/googleapis.drive;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;

drive:ConnectionConfig config = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

remote_client:ConnectionConfig rm_client_config = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

resource_client:ConnectionConfig rs_client_config = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

drive:Client driveClient = check new (config);
remote_client:Client gdriveRemoteClient = check new (rm_client_config);
resource_client:Client gdriveResourceClient = check new (rs_client_config);
string localFilePath = "sample.json";

public function main() returns error? {
    // Upload using existing drive client
    drive:File res1 = check driveClient->uploadFile(localFilePath);
    string fileId = res1.id.toString();
    io:println("file Id: ", fileId);

    byte[] fileContentByteArray = check io:fileReadBytes(localFilePath);

    // Upload using remote client
    remote_client:File res2 = check gdriveRemoteClient->driveFilesCreate(fileContentByteArray);
    string id = res2.id.toString();
    io:println("file Id: ", id);

    // Upload using resource client
    resource_client:File res3 = check gdriveResourceClient->/files.post(fileContentByteArray);
    id = res3.id.toString();
    io:println("file Id: ", id);



    // Create comment using remote client
    remote_client:Comment comment1 = {
        content: "Create a comment using remote client"
    };
    remote_client:Comment driveCommentsCreate1 = check gdriveRemoteClient->driveCommentsCreate(fileId, comment1, fields = "id, content");
    string commentId1 = driveCommentsCreate1.id.toString();
    io:println("comment Id: ", commentId1);
    io:println(<string>driveCommentsCreate1.content);

    // Create comment using resource client
    resource_client:Comment comment2 = {
        content: "Create a comment using resource client"
    };
    resource_client:Comment driveCommentsCreate2 = check gdriveResourceClient->/files/[fileId]/comments.post(comment2, fields = "id, content");
    string commentId2 = driveCommentsCreate2.id.toString();
    io:println("comment Id: ", commentId2);
    io:println(<string>driveCommentsCreate2.content);



    // update comment using remote client
    comment1.content = "Updated the comment using remote client";
    comment1 = check gdriveRemoteClient->driveCommentsUpdate(fileId, commentId1, comment1, fields = "content");
    io:println(<string>comment1.content);

    // update comment using resource client
    comment2.content = "Updated the comment using resource client";
    comment2 = check gdriveResourceClient->/files/[fileId]/comments/[commentId2].patch(comment2, fields = "content");
    io:println(<string>comment2.content);



    // Delete comment using remote client
    http:Response driveCommentsDelete = check gdriveRemoteClient->driveCommentsDelete(fileId, commentId1);
    io:println(driveCommentsDelete.statusCode.toString());

    // Delete comment using resource client
    driveCommentsDelete = check gdriveResourceClient->/files/[fileId]/comments/[commentId2].delete();
    io:println(driveCommentsDelete.statusCode.toString());
}
