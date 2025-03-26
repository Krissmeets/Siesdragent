public with sharing class S4S_SDR_Lead_Data_Binder {
//*************************************************************************************************************************************
//@ Description : SDR Agent get detail from the lead and inject this into the outreach prompt 
//@ Author      : Christoffel Smeets (ksmeets@salesforce.com)          
//@ Date        : 21 March 2025        
//@ Test Class  : S4S_SDR_Lead_Data_BinderTest
//**************************************************************************************************************************************
    
    private static string letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    @InvocableMethod(   label='SDR Lead Data Prompt Binder'
                        description='Inject various data attributes dynamically into the prompt'
                        CapabilityType='PromptTemplateType://einstein_gpt__einsteinSdrEmail')
    public static List<Response> getPrompt(List<Request> requests) {
        //### standard variables
        Request req = requests[0];
        List<Response> responses = new List<Response>();
        Response output = new Response();

        //### Create Map with Lead Fields
        integer i = 0;
        Set<String> queryFields = new Set<String>();
        Map<string,Field> leadReference = new Map<string,Field>(); 
        for (S4S_Prompt_Binding__c f : [SELECT Field__c, Value__c from S4S_Prompt_Binding__c 
                                        WHERE Name = 'Lead' AND Key__c = '###HEADER###']) {
            leadReference.put(letters.substring(i,1), new Field(f.Field__c, f.Value__c));
            queryFields.add(f.Field__c);
            i++;
        }
      
        //### Query the Lead object again to make sure all fields are available
        string queryLead = string.format('SELECT {0} FROM LEAD WHERE Id =\'\'{1}\'\' LIMIT 1',new list<object>{string.join(queryFields,','), req.Recipient.Id});
        system.debug(queryLead);

        Lead lead = (Lead) Database.query(queryLead);
        system.debug(lead);

        //### Build the bindmap to be used when executed the database query
        Map<String, Object> bindMap = new Map<String, Object>();
        for (string f : leadReference.keySet()) {
            try {
                bindMap.put(f, lead.get(leadReference.get(f).name) ?? '$$$NOTAVAILABLE$$$');
            } catch (Exception e) {
				bindMap.put(f, '$$$NOTAVAILABLE$$$');
            }
        }
        system.debug(bindMap);

        //### Concatenate the whereclauses for the query
        String[] whereClauses = new list<string>();
        for (string f : leadReference.keyset()) {
            whereClauses.add(string.format('(Name = \'Lead\' AND Field__c=\'\'{0}\'\' AND Key__c=:{1})', new List<object>{leadReference.get(f).name, f}));
        }

        //### Build the query
        String query = 'SELECT Name,Field__c,Value__c FROM S4S_Prompt_Binding__c WHERE ';
        query += string.join(whereClauses, ' OR ');
        system.debug(query);

        //### Execute the query and create a map: name=>object
        Map<string, S4S_Prompt_Binding__c> promptMap = new Map<string, S4S_Prompt_Binding__c>();
        for (S4S_Prompt_Binding__c f : (List<S4S_Prompt_Binding__c>) Database.queryWithBinds(query,bindMap, AccessLevel.USER_MODE)) {
            promptMap.put(f.Name+f.Field__c, f);
            system.debug('Binding:' + f.Name+f.Field__c);
        }

        //### Build the output prompt
        output.Prompt = '';
        for (string f : leadReference.keySet()) {
            string key = 'Lead' + leadReference.get(f).name;
            if (promptMap.containsKey(key)) {
                output.Prompt += leadReference.get(f).description + '\n';
                output.Prompt += promptMap.get(key).Value__c + '\n' + '\n';
            }
        }
           
        responses.add(output);
        return responses;
    }

    private class Field {
        string name;
        string description;
        public Field(string name, string description) {
            this.name = name;
            this.description = description;
        }
    }

    // Type and API Name of all variables must match the template
    public class Request {
        @InvocableVariable(required=true)
        public Lead Recipient;   
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }


}