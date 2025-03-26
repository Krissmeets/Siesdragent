@isTest
private class S4S_SDR_Lead_QualifiedTest {
    
    @TestSetup static void testData() {  
        system.debug('@testsetup');
    }


@IsTest
    static void updateLeadStatus() {

        User u = S4S_SDR_Lead_QualifiedTest.createUser();

        List<PermissionSet> lps = [SELECT Id FROM PermissionSet WHERE Name IN ('EinsteinSdrAgent', 'S4S_SDR_Agent')];
        List<PermissionSetAssignment> lpsa = new List<PermissionSetAssignment>();
        for (PermissionSet ps : lps) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            lpsa.add(psa);
        }
        insert lpsa;

        Test.startTest();
        
        System.runAs(u) {


        RecordType leadRecordType = [select Id from RecordType where SobjectType = 'Lead' and DeveloperName = 'S4SInternal' limit 1];
        Lead l = new Lead (
            RecordTypeId = leadRecordType.Id,
            FirstName = 'John',
            S4SDivision__c  = 'IOT',
            Status = 'SDR Unqualified',
            Industry = 'Automotive',
            LastName = 'Doe' + String.valueOf(Math.random()).substring(2),             
            Company = 'Acme Corp',       
            Street = '123 Main St',        
            City = 'Sample City',         
            PostalCode = '90001',
            Country = 'DE',              
            Email = 'john.doe@example.com');
        insert l;

        List<S4S_SDR_Lead_Qualfied.Request> requests = new List<S4S_SDR_Lead_Qualfied.Request>();
        S4S_SDR_Lead_Qualfied.Request request = new S4S_SDR_Lead_Qualfied.Request();
        Lead lead = [SELECT Id From Lead limit 1];
        request.lead = lead;
        requests.add(request);

            List<S4S_SDR_Lead_Qualfied.Response> responses = S4S_SDR_Lead_Qualfied.sdrLeadQualfied(requests);
            system.assert(responses[0].success);  
        }
        Test.stopTest();     

    }

    private static User createUser() {
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'test@test.com';
        u.Username = 'testsdr2' + String.valueOf(Math.random()).substring(2) + '@siemens.test';
        u.Alias = 'tuser';
        u.CommunityNickname = 'tuser';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name='Einstein Agent User'].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
    
        return u;
    }
}