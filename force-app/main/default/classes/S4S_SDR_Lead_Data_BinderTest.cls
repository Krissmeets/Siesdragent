@isTest
private class S4S_SDR_Lead_Data_BinderTest {

    @TestSetup static void testData() {  
        String[] keys = new String[]{'###HEADER###', 'Automotive','Aerospace'};
        List<S4S_Prompt_Binding__c> lpb = new List<S4S_Prompt_Binding__c>();

        for (string f: keys) {
            S4S_Prompt_Binding__c pb = new S4S_Prompt_Binding__c();
            pb.Name = 'Lead';
            pb.Field__c = 'Industry'; 
            pb.Key__c = f;
            pb.Value__c = 'TEST HEADER:';
            lpb.add(pb);
        }   
        insert lpb;

        Lead l = new Lead (
            FirstName = 'John',
            S4SDivision__c  = 'IOT',
            Industry = 'Automotive',
            LastName = 'Doe',             
            Company = 'Acme Corp',       
            Street = '123 Main St',        
            City = 'Sample City',         
            PostalCode = '90001',
            Country = 'DE',              
            Email = 'john.doe@example.com');
        insert l;

    }


@IsTest
    static void testGetPrompt() {
        S4S_SDR_Lead_Data_Binder.Request request = new S4S_SDR_Lead_Data_Binder.Request();
        List<S4S_SDR_Lead_Data_Binder.Request> requests = new List<S4S_SDR_Lead_Data_Binder.Request>();
        requests.add(request);

        S4S_SDR_Lead_Data_Binder.Response response = new S4S_SDR_Lead_Data_Binder.Response();
        List<S4S_SDR_Lead_Data_Binder.Response> responses = new List<S4S_SDR_Lead_Data_Binder.Response>();
        responses.add(response);

        User u = S4S_SDR_Lead_Data_BinderTest.createUser();
        
        List<PermissionSet> lps = [SELECT Id FROM PermissionSet WHERE Name IN ('S4S_SDR_Lead_Data_Binder', 'S4SSkipValidations')];
        for (PermissionSet ps : lps) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            insert psa; 
        }

        Test.startTest();
       
        System.runAs(u) {
        //### Run the test
          system.debug(u);  
        // responses = S4S_SDR_Lead_Data_Binder.getPrompt(requests);
        }
        Test.stopTest();


        //### Check the results
        //response = responses[0];
        //System.assertEquals('This is a test Lead\nThis is a test Value', response.Prompt);
    }

    public static User createUser() {
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'test@test.com';
        u.Username = 'testuser' + String.valueOf(Math.random()).substring(2) + '@siemens.test';
        u.Alias = 'tuser';
        u.CommunityNickname = 'tuser';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
    
        return u;
    }
}