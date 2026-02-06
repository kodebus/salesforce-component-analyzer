public with sharing class ComponentAnalyzerController {
    
    /**
     * Retrieves all OmniScripts from the org
     */
    @AuraEnabled(cacheable=false)
    public static List<ComponentWrapper> getOmniScripts() {
        List<ComponentWrapper> components = new List<ComponentWrapper>();
        
        try {
            // Query OmniScripts - adjust namespace as needed (vlocity_cmt, vlocity_ins, omnistudio)
            List<SObject> omniscripts = Database.query(
                'SELECT Id, Name, ' +
                getNamespacePrefix() + 'Type__c, ' +
                getNamespacePrefix() + 'SubType__c, ' +
                getNamespacePrefix() + 'Language__c, ' +
                getNamespacePrefix() + 'IsActive__c, ' +
                getNamespacePrefix() + 'PropertySetConfig__c, ' +
                'LastModifiedDate, ' +
                'LastModifiedBy.Name ' +
                'FROM ' + getNamespacePrefix() + 'OmniScript__c ' +
                'ORDER BY Name'
            );
            
            for (SObject os : omniscripts) {
                ComponentWrapper wrapper = new ComponentWrapper();
                wrapper.id = (String)os.get('Id');
                wrapper.name = (String)os.get('Name');
                wrapper.type = (String)os.get(getNamespacePrefix() + 'Type__c');
                wrapper.subType = (String)os.get(getNamespacePrefix() + 'SubType__c');
                wrapper.language = (String)os.get(getNamespacePrefix() + 'Language__c');
                wrapper.status = (Boolean)os.get(getNamespacePrefix() + 'IsActive__c') ? 'Active' : 'Inactive';
                wrapper.lastModified = ((DateTime)os.get('LastModifiedDate')).format('MM/dd/yyyy');
                wrapper.lastModifiedBy = (String)os.getSObject('LastModifiedBy')?.get('Name');
                wrapper.description = 'OmniScript: ' + wrapper.type + '/' + wrapper.subType + '/' + wrapper.language;
                
                // Parse PropertySetConfig for additional metadata
                String propertySet = (String)os.get(getNamespacePrefix() + 'PropertySetConfig__c');
                if (String.isNotBlank(propertySet)) {
                    wrapper.configuration = propertySet;
                }
                
                components.add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving OmniScripts: ' + e.getMessage());
        }
        
        return components;
    }
    
    /**
     * Retrieves all DataRaptors from the org
     */
    @AuraEnabled(cacheable=false)
    public static List<ComponentWrapper> getDataRaptors() {
        List<ComponentWrapper> components = new List<ComponentWrapper>();
        
        try {
            List<SObject> dataRaptors = Database.query(
                'SELECT Id, Name, ' +
                getNamespacePrefix() + 'Type__c, ' +
                getNamespacePrefix() + 'InputType__c, ' +
                getNamespacePrefix() + 'OutputType__c, ' +
                getNamespacePrefix() + 'IsActive__c, ' +
                'LastModifiedDate, ' +
                'LastModifiedBy.Name ' +
                'FROM ' + getNamespacePrefix() + 'DRBundle__c ' +
                'ORDER BY Name'
            );
            
            for (SObject dr : dataRaptors) {
                ComponentWrapper wrapper = new ComponentWrapper();
                wrapper.id = (String)dr.get('Id');
                wrapper.name = (String)dr.get('Name');
                wrapper.type = (String)dr.get(getNamespacePrefix() + 'Type__c');
                wrapper.status = (Boolean)dr.get(getNamespacePrefix() + 'IsActive__c') ? 'Active' : 'Inactive';
                wrapper.lastModified = ((DateTime)dr.get('LastModifiedDate')).format('MM/dd/yyyy');
                wrapper.lastModifiedBy = (String)dr.getSObject('LastModifiedBy')?.get('Name');
                
                String inputType = (String)dr.get(getNamespacePrefix() + 'InputType__c');
                String outputType = (String)dr.get(getNamespacePrefix() + 'OutputType__c');
                wrapper.description = 'DataRaptor ' + wrapper.type + 
                    (inputType != null ? ' (In: ' + inputType + ')' : '') +
                    (outputType != null ? ' (Out: ' + outputType + ')' : '');
                
                components.add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving DataRaptors: ' + e.getMessage());
        }
        
        return components;
    }
    
    /**
     * Retrieves all Integration Procedures from the org
     */
    @AuraEnabled(cacheable=false)
    public static List<ComponentWrapper> getIntegrationProcedures() {
        List<ComponentWrapper> components = new List<ComponentWrapper>();
        
        try {
            List<SObject> ips = Database.query(
                'SELECT Id, Name, ' +
                getNamespacePrefix() + 'Type__c, ' +
                getNamespacePrefix() + 'SubType__c, ' +
                getNamespacePrefix() + 'IsActive__c, ' +
                getNamespacePrefix() + 'PropertySetConfig__c, ' +
                'LastModifiedDate, ' +
                'LastModifiedBy.Name ' +
                'FROM ' + getNamespacePrefix() + 'OmniProcess__c ' +
                'ORDER BY Name'
            );
            
            for (SObject ip : ips) {
                ComponentWrapper wrapper = new ComponentWrapper();
                wrapper.id = (String)ip.get('Id');
                wrapper.name = (String)ip.get('Name');
                wrapper.type = (String)ip.get(getNamespacePrefix() + 'Type__c');
                wrapper.subType = (String)ip.get(getNamespacePrefix() + 'SubType__c');
                wrapper.status = (Boolean)ip.get(getNamespacePrefix() + 'IsActive__c') ? 'Active' : 'Inactive';
                wrapper.lastModified = ((DateTime)ip.get('LastModifiedDate')).format('MM/dd/yyyy');
                wrapper.lastModifiedBy = (String)ip.getSObject('LastModifiedBy')?.get('Name');
                wrapper.description = 'Integration Procedure: ' + wrapper.type + '/' + wrapper.subType;
                
                String propertySet = (String)ip.get(getNamespacePrefix() + 'PropertySetConfig__c');
                if (String.isNotBlank(propertySet)) {
                    wrapper.configuration = propertySet;
                }
                
                components.add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Integration Procedures: ' + e.getMessage());
        }
        
        return components;
    }
    
    /**
     * Retrieves all FlexCards from the org
     */
    @AuraEnabled(cacheable=false)
    public static List<ComponentWrapper> getFlexCards() {
        List<ComponentWrapper> components = new List<ComponentWrapper>();
        
        try {
            List<SObject> flexCards = Database.query(
                'SELECT Id, Name, ' +
                getNamespacePrefix() + 'Author__c, ' +
                getNamespacePrefix() + 'IsActive__c, ' +
                'LastModifiedDate, ' +
                'LastModifiedBy.Name ' +
                'FROM ' + getNamespacePrefix() + 'OmniUiCard__c ' +
                'ORDER BY Name'
            );
            
            for (SObject fc : flexCards) {
                ComponentWrapper wrapper = new ComponentWrapper();
                wrapper.id = (String)fc.get('Id');
                wrapper.name = (String)fc.get('Name');
                wrapper.status = (Boolean)fc.get(getNamespacePrefix() + 'IsActive__c') ? 'Active' : 'Inactive';
                wrapper.lastModified = ((DateTime)fc.get('LastModifiedDate')).format('MM/dd/yyyy');
                wrapper.lastModifiedBy = (String)fc.getSObject('LastModifiedBy')?.get('Name');
                wrapper.description = 'FlexCard';
                
                components.add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving FlexCards: ' + e.getMessage());
        }
        
        return components;
    }
    
    /**
     * Retrieves Lightning Web Components using Tooling API
     */
    @AuraEnabled(cacheable=false)
    public static List<ComponentWrapper> getLightningWebComponents() {
        List<ComponentWrapper> components = new List<ComponentWrapper>();
        
        try {
            // Query Lightning Web Component Bundles
            String endpoint = '/services/data/v60.0/tooling/query/?q=';
            String query = 'SELECT Id, DeveloperName, NamespacePrefix, ApiVersion, LastModifiedDate, LastModifiedBy.Name ' +
                          'FROM LightningComponentBundle ' +
                          'WHERE NamespacePrefix = null ' +
                          'ORDER BY DeveloperName';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Salesforce_Tooling_API' + endpoint + EncodingUtil.urlEncode(query, 'UTF-8'));
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                List<Object> records = (List<Object>)result.get('records');
                
                for (Object record : records) {
                    Map<String, Object> lwc = (Map<String, Object>)record;
                    ComponentWrapper wrapper = new ComponentWrapper();
                    wrapper.id = (String)lwc.get('Id');
                    wrapper.name = (String)lwc.get('DeveloperName');
                    wrapper.type = 'Lightning Web Component';
                    wrapper.status = 'Active';
                    wrapper.description = 'LWC Component';
                    
                    components.add(wrapper);
                }
            }
        } catch (Exception e) {
            // If Tooling API fails, return empty list with note
            System.debug('Could not retrieve LWCs via Tooling API: ' + e.getMessage());
        }
        
        return components;
    }
    
    /**
     * Retrieves Flows using Tooling API
     */
    @AuraEnabled(cacheable=false)
    public static List<ComponentWrapper> getFlows() {
        List<ComponentWrapper> components = new List<ComponentWrapper>();
        
        try {
            List<FlowDefinitionView> flows = [
                SELECT ApiName, Label, ProcessType, ActiveVersionId, LastModifiedDate, LastModifiedBy.Name
                FROM FlowDefinitionView
                ORDER BY Label
            ];
            
            for (FlowDefinitionView flow : flows) {
                ComponentWrapper wrapper = new ComponentWrapper();
                wrapper.id = flow.ActiveVersionId;
                wrapper.name = flow.Label;
                wrapper.type = flow.ProcessType;
                wrapper.status = flow.ActiveVersionId != null ? 'Active' : 'Inactive';
                wrapper.lastModified = flow.LastModifiedDate?.format('MM/dd/yyyy');
                wrapper.description = 'Flow: ' + flow.ProcessType;
                
                components.add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Flows: ' + e.getMessage());
        }
        
        return components;
    }
    
    /**
     * Analyzes component dependencies
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, List<String>> getComponentDependencies(String componentId, String componentType) {
        Map<String, List<String>> dependencies = new Map<String, List<String>>();
        dependencies.put('uses', new List<String>());
        dependencies.put('usedBy', new List<String>());
        
        try {
            if (componentType == 'OmniScript') {
                dependencies = OmniScriptDependencyParser.parseDependencies(componentId);
            } else if (componentType == 'Integration Procedure') {
                dependencies = IntegrationProcedureDependencyParser.parseDependencies(componentId);
            } else if (componentType == 'DataRaptor') {
                dependencies = DataRaptorDependencyParser.parseDependencies(componentId);
            }
        } catch (Exception e) {
            System.debug('Error parsing dependencies: ' + e.getMessage());
        }
        
        return dependencies;
    }
    
    /**
     * Helper method to get the correct namespace prefix for OmniStudio objects
     */
    private static String getNamespacePrefix() {
        // Try to detect which namespace is installed
        String namespace = 'vlocity_cmt__'; // Default
        
        try {
            List<SObject> testQuery = Database.query('SELECT Id FROM vlocity_cmt__OmniScript__c LIMIT 1');
            return 'vlocity_cmt__';
        } catch (Exception e) {
            // vlocity_cmt not found
        }
        
        try {
            List<SObject> testQuery = Database.query('SELECT Id FROM vlocity_ins__OmniScript__c LIMIT 1');
            return 'vlocity_ins__';
        } catch (Exception e) {
            // vlocity_ins not found
        }
        
        try {
            List<SObject> testQuery = Database.query('SELECT Id FROM omnistudio__OmniScript__c LIMIT 1');
            return 'omnistudio__';
        } catch (Exception e) {
            // omnistudio not found
        }
        
        return 'vlocity_cmt__'; // Return default if none found
    }
    
    /**
     * Wrapper class for component data
     */
    public class ComponentWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String subType;
        @AuraEnabled public String language;
        @AuraEnabled public String status;
        @AuraEnabled public String description;
        @AuraEnabled public String lastModified;
        @AuraEnabled public String lastModifiedBy;
        @AuraEnabled public String configuration;
    }
}
