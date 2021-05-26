/**
 * Created by voduyemi on 5/25/21.
 */

public with sharing class CustomNotificationDemo {
    public static void notifyUsers(Set<String> recipientsIds, String targetId) {

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [
                SELECT Id, DeveloperName
                FROM CustomNotificationType
                WHERE DeveloperName = 'Processed_Gifts'
        ];

        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Batch Gift Processing');
        notification.setBody('All the gifts in your batch have been processed');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);

        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

}