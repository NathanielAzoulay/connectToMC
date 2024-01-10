public class JsonGenerator {

    @InvocableVariable(required = false label='jsonData'  )
    @AuraEnabled
    public string jsonData;
    
    @InvocableVariable(required = false label='jsonstring'  )
    @AuraEnabled 
    public list<string> jsonstring;

    @InvocableVariable(required = false label='key'  )
    @AuraEnabled
    public String key; 
    
    @InvocableVariable(required = false label='value')
    @AuraEnabled
    public String value;

    @InvocableVariable(required = false label='parentLevel')
    @AuraEnabled
    public String parentLevel;

    @InvocableVariable(required = false label='type')
    @AuraEnabled
    public String type;

    @InvocableVariable(required = false label='isList')
    @AuraEnabled
    public String isList;

    @InvocableVariable(required = false label='fromObject')
    @AuraEnabled
    public String fromObject;

    @InvocableVariable(required = false label='jsonName')
    @AuraEnabled
    public String jsonName;

    @InvocableVariable(required = false label='level')
    @AuraEnabled
    public Integer level;

    public class inputFromFlow {
        @InvocableVariable(required = false label='definitionKey')
        @AuraEnabled
        public String definitionKey;
    
        @InvocableVariable(required = false label='primaryObject')
        @AuraEnabled
        public Id primaryObject;
    
        @InvocableVariable(required = false label='subList')
        @AuraEnabled
        public List<Id> subList;
    }

    public class OutputFromFlow {
        @InvocableVariable(label='Json Body')
        public String JsonBody;
    }

    @InvocableMethod(label='build Json')
    public static List<OutputFromFlow> buildJson(List<inputFromFlow> param) { 

        List<JsonGenerator> primaryList = receiveDatList(param[0].definitionKey, param[0].primaryObject);
        List<JsonGenerator> subList = receiveDatSubList(param[0].definitionKey, param[0].subList);

        String listMessageKey = BuildDynamicJson(primaryList, subList);

        List<OutputFromFlow> output = new List<OutputFromFlow>();
        OutputFromFlow outputFromFlow = new OutputFromFlow();
        outputFromFlow.JsonBody = listMessageKey;
        output.add(outputFromFlow);
        return output;
    }

    public static List<JsonGenerator> receiveDatList(String definitionKey, Id primaryObject) {
       List<JsonMapping__mdt> mdtJsonMappingList = [SELECT Id, Email_Definition__c, From__c, isList__c, JsonName__c, key__c, level__c, parentLevel__c, type__c, value__c 
                                                    FROM JsonMapping__mdt
                                                    WHERE Email_Definition__c =: definitionKey AND JsonName__c = null AND isActive__c = true];

        String fromObject = '';
        List<JsonGenerator> objArrayList = new List<JsonGenerator>();
        for (JsonMapping__mdt mdt : mdtJsonMappingList) {
            JsonGenerator obj = new JsonGenerator();
            obj.key = mdt.key__c;
            obj.value = mdt.value__c;
            obj.parentLevel = mdt.parentLevel__c;
            obj.type = mdt.type__c;
            obj.isList = mdt.isList__c;
            obj.fromObject = mdt.From__c;
            obj.jsonName = mdt.JsonName__c;
            objArrayList.add(obj);
            if (fromObject == null || fromObject == '') {
                fromObject = mdt.From__c;
            }
        }

        List<String> listValue = new List<String>();
		for (JsonMapping__mdt listReceiveValue : mdtJsonMappingList) {
		    if(listReceiveValue.From__c != null) { 
		        listValue.add(listReceiveValue.value__c);
		    }
		}
           
        System.debug('fromObject: ' + fromObject);
        String dataJsonValue = String.join(listValue, ',');
        
        System.debug('@@dataJsonValue: ' + dataJsonValue);

        String soqlQuery = 'SELECT ' + dataJsonValue + ' FROM ' + fromObject + ' WHERE Id = \'' + primaryObject + '\'';
        System.debug('@@soqlQuery: ' + soqlQuery);
        List<SObject> valueFromSelect = Database.query(soqlQuery);        

        for (JsonGenerator obj : objArrayList) {
            if(obj.fromObject != null && !obj.value.contains('.') ) { 
                obj.value = String.valueOf(valueFromSelect[0].get(obj.value));
            } else if(obj.fromObject != null && obj.value.contains('.') ) {
                String objectName = obj.value.substringBefore('.');
                obj.value = String.valueOf(valueFromSelect[0].getSObject(objectName).get(obj.value.substringAfter('.')));
            }
        }

        System.debug('@@objArrayList1: ' + objArrayList);

        return objArrayList;
    }

    public static List<JsonGenerator> receiveDatSubList (String definitionKey, List<Id> subList) {
        subList =  new List<Id>{'8021x000007NwwoAAC' , '8021x000007NwwpAAC'}; // , '8021x000007NwwpAAC'
        Integer countSubListId = 0;
        List<JsonMapping__mdt> mdtJsonMappingList = [SELECT Id, Email_Definition__c, From__c, isList__c, JsonName__c, key__c, level__c, parentLevel__c, type__c, value__c 
                                                    FROM JsonMapping__mdt
                                                    WHERE Email_Definition__c =: definitionKey AND JsonName__c != null AND isActive__c = true];
    
        List<JsonGenerator> objArraySubList = new List<JsonGenerator>();
        Map<String, JsonGenerator> keyToObjMap = new Map<String, JsonGenerator>();
        // i want to obtain the value for the From__c in my mdt maybe not all record in mdtJsonMappingList have the from__c but i want only 1 with data in this column
        String fromObject = '';
        
        for (JsonMapping__mdt mdt : mdtJsonMappingList) {
            JsonGenerator obj = new JsonGenerator();
            obj.key = mdt.key__c;
            obj.value = mdt.value__c;
            obj.parentLevel = mdt.parentLevel__c;
            obj.type = mdt.type__c;
            obj.isList = mdt.isList__c;
            obj.fromObject = mdt.From__c;
            obj.jsonName = mdt.JsonName__c;
            objArraySubList.add(obj);
            keyToObjMap.put(mdt.key__c, obj);
            if (fromObject == null || fromObject == '') {
                fromObject = mdt.From__c;
            }
        }

        List<String> listValue = new List<String>();
        for (JsonMapping__mdt listReceiveValue : mdtJsonMappingList) {
            if(listReceiveValue.From__c != null) { 
                listValue.add(listReceiveValue.value__c);
            }
        }
           
        String dataJsonValue = String.join(listValue, ',');
        List<JsonGenerator> finalList = new List<JsonGenerator>();
        List<JsonGenerator> allObjects = new List<JsonGenerator>();
        for (Id subListId : subList) {
            String soqlQuery = 'SELECT ' + dataJsonValue + ' FROM ' + fromObject + ' WHERE Id = \'' + subListId + '\'';
            System.debug('@@soqlQuery: ' + soqlQuery);
            List<SObject> valueFromSelect = Database.query(soqlQuery);  
            System.debug('valueFromSelect' + valueFromSelect);      
            countSubListId++;    
 
            for (SObject item : valueFromSelect) {
                for (JsonMapping__mdt mdt : mdtJsonMappingList) {
                    if(mdt.From__c != null) { 
                        JsonGenerator obj = keyToObjMap.get(mdt.key__c).clone();
                        System.debug('@@obj' +  obj);
                        if(obj != null && !obj.value.contains('.')) {
                            obj.value = String.valueOf(valueFromSelect[0].get(mdt.value__c));
                            allObjects.add(obj);
                        } else if( obj != null && obj.value.contains('.')) {
                            String objectName = obj.value.substringBefore('.');
                            obj.value = String.valueOf(valueFromSelect[0].getSObject(objectName).get(obj.value.substringAfter('.')));
                            allObjects.add(obj);
                        }
                    }
                    
                }
            }
        }

        for (JsonMapping__mdt mdt : mdtJsonMappingList) {
            if(mdt.From__c == null) {
                JsonGenerator obj = new JsonGenerator();
                obj.key = mdt.key__c;
                obj.value = mdt.value__c;
                obj.parentLevel = mdt.parentLevel__c;
                obj.type = mdt.type__c;
                obj.isList = mdt.isList__c;
                obj.fromObject = mdt.From__c;
                obj.jsonName = mdt.JsonName__c;
                allObjects.add(obj);
            }
        }

        System.debug('@@allObjects: ' + allObjects);
        return allObjects;
    }

    public static String BuildDynamicJson(List<JsonGenerator> primaryList, List<JsonGenerator> subList) {
        System.debug('@@primaryList: ' + primaryList);
        System.debug('@@subList: ' + subList);
        Map<String, Object> jsonMap = new Map<String, Object>();
        List<Map<String, Object>> recipientsList = new List<Map<String, Object>>();
        Map<String, Object> recipientMap = new Map<String, Object>();
        Map<String, Object> attributesMap = new Map<String, Object>();
        String nameKeySubList = '';

        for (JsonGenerator obj : primaryList) {
            if (obj.parentLevel != null) {
                if (obj.parentLevel == 'recipient') {
                    recipientMap.put(obj.key, obj.value);
                } else if (obj.parentLevel == 'attributes') {
                    attributesMap.put(obj.key, obj.value);
                }
            } else {
                jsonMap.put(obj.key, obj.value);
            }
        }
    
        List<Map<String, Object>> subListDetail = new List<Map<String, Object>>();
        Map<String, Object> currentProduct = null;
        
        for (JsonGenerator obj : subList) {
            if (obj.isList == 'true') {
                if (currentProduct != null && !currentProduct.isEmpty()) {
                    subListDetail.add(currentProduct);
                }
                currentProduct = new Map<String, Object>();
            }
            if (currentProduct != null && obj.key != null && obj.value != null) {
                currentProduct.put(obj.key, obj.value);
            }
            if (obj.value == null && obj.type == 'list') {
                nameKeySubList = obj.key;
            }
        }

        if (currentProduct != null && !currentProduct.isEmpty()) {
            subListDetail.add(currentProduct);
        }
    
        if (!subListDetail.isEmpty()) {
            Map<String, Object> subListMap = new Map<String, Object>();
            subListMap.put('subList', subListDetail);
            String productsDetailString = JSON.serialize(subListMap);
            productsDetailString = productsDetailString.replace('"', '\"');
            attributesMap.put(nameKeySubList, productsDetailString);
        }
        if (!attributesMap.isEmpty()) {
            recipientMap.put('attributes', attributesMap);
        }
        if (!recipientMap.isEmpty()) {
            recipientsList.add(recipientMap);
        }
    
        if (!recipientsList.isEmpty()) {
            jsonMap.put('recipients', recipientsList);
        }
    
        String jsonString = JSON.serialize(jsonMap);
        System.debug('@@jsonString: ' + jsonString);
        return jsonString;
    }
}
