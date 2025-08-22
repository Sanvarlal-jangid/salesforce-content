trigger smstrigger on Student__c (after insert) {
    
    for(Student__c st : trigger.new){
        sendmessagetostudent.mymethod(st.First_Name__c,st.phone_no__c,st.email__c);
    }
}