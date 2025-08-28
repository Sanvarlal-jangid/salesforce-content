public class emailtoemployee {
    
   public static void sendmail(Id empId, String name, Decimal bonus, Decimal CTC, Decimal mPay, Decimal avgRating, String email, Map<Id, Performance__c> empAndPerfMap) {
    Performance__c p = empAndPerfMap.get(empId);
    Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
    List<String> emailAddress = new List<String>{ email };
    sem.setToAddresses(emailAddress);
    sem.setSubject('Performance Review Mail');

    String body;
    if (avgRating < 2) {
        body = 'Hi ' + name + ',\n\n'
            + 'I hope this email finds you well. We need to inform you that your performance last month was not great. '
            + 'You received an average rating of ' + avgRating + ', and we encourage you to step up your performance and work harder. '
            + 'Otherwise, we may be forced to make some unwanted decisions.\n\n'
            + 'If you have any queries related to this, feel free to reach out to your manager.\n\n'
            + 'Thanks & Regards,\n'
            + 'HR Department';
    } else {
        body = 'Hi ' + name + ',\n\n'
            + 'I hope this email finds you well. We are delighted to inform you that your recent performance review has been completed. '
            + 'You received a rating of ' + p.Rating__c + ', and the feedback from your manager was: "' + p.Feedback__c + '".\n\n'
            + 'Based on your performance, you have been awarded a bonus of ' + bonus + '. '
            + 'Your revised CTC is ' + CTC + ', and your updated monthly pay is ' + mPay + '.\n\n'
            + 'If you have any queries related to this, feel free to reach out to your manager.\n\n'
            + 'Thanks & Regards,\n'
            + 'HR Department';
    }

    sem.setPlainTextBody(body);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{sem});
}


}