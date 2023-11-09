/*
 * Created by Oleg Bogdanovych on 7/8/2019.
 */
global without sharing class SiteSurveyFormController {
    public Id workOrderId {get; Set;}
    public Id surveyId {get; Set;}

    public SiteSurveyFormController() {
        workOrderId  = ApexPages.CurrentPage().getparameters().get('workOrder');
        surveyId = [SELECT Site_Survey__c FROM WorkOrder WHERE Id = :workOrderId].Site_Survey__c;
    }

    @AuraEnabled
    public static WorkOrder getWorkOrder(String woId) {
        return [SELECT
                    Id, WorkOrderNumber, Bespoke_Hardware__c, Site_Survey_Send__c, Site_Survey__c, AccountId,
                    Contact.Name, Contact_Email__c, Survey_Sent_Remind_Date__c, ContactId, Opportunity__c,
                    Bespoke_HW_availability__c, Bespoke_HW_Contact__c, Bespoke_HW_requested__c,
                    Bespoke_HW_available__c, Opportunity__r.Sales_Support__c, Technical_Information_Contact__c,
                    Technical_Information_Contact__r.Name, Technical_Information_Contact__r.Email,
                    Site_Survey__r.ICAPS_Number__c, Site_Survey_Reviewed_by_TC__c, Responsible_Engineer_Contact__c,
                    Responsible_Engineer_Contact__r.Name, Responsible_Engineer_Contact__r.Email,
                    Travel_Booked__c, DGA__c, BM__c, TFC__c, Site_Survey__r.Completed__c
                FROM WorkOrder
                WHERE Id = :woId];
    }

    @AuraEnabled
    public static List<FieldSetData> getFieldSetFields(List<String> fieldSets) {
        List<FieldSetData> toReturn = new List<FieldSetData>();

        Map<String, Schema.FieldSet> fsMap = Site_Survey__c.SObjectType.getDescribe().fieldSets.getMap();

        for (String fsName: fieldSets) {
            Schema.FieldSet fs = fsMap.get(fsName);

            if (fs != null) {
                toReturn.add(new FieldSetData(fs));
            }
        }

        return toReturn;
    }

    @AuraEnabled
    public static WorkOrder sendBespokeAvailableEmail(String woId) {
        WorkOrder wo = getWorkOrder(woId);

        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'FSL_Populate_Bespoke_HW_Date'];

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTargetObjectId(wo.Bespoke_HW_availability__c);
        msg.setCcAddresses(new List<String>{wo.Opportunity__r.Sales_Support__c});
        msg.setTemplateID(et.Id);
        msg.setWhatId(wo.Id);

        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'donotreply@camlinenergy.com'];
        if (owea.size() > 0) {
            msg.setOrgWideEmailAddressId(owea[0].Id);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {msg});
        if (results[0].success) {
       
            wo.Bespoke_HW_requested__c = Date.today();
    
            update wo;
        } else {
            throw new AuraHandledException('The email failed to send: ' + results[0].errors[0].message);
        }

        
        return wo;
    }

    @AuraEnabled
    public static WorkOrder sentSurveyEmail(String woId) {
        WorkOrder wo = getWorkOrder(woId);

        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'FSL_Site_Survey_Form_To_Customer'];

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTargetObjectId(wo.Technical_Information_Contact__c);
        msg.setTemplateID(et.Id);
        msg.setWhatId(wo.Id);

        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'donotreply@camlinenergy.com'];
        if (owea.size() > 0) {
            msg.setOrgWideEmailAddressId(owea[0].Id);
        }
        
         
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {msg});
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            wo.Site_Survey_Send__c = Date.today();
            wo.Survey_Sent_Remind_Date__c = Date.today();
    
            update wo;
        } else {
            throw new AuraHandledException('The email failed to send: ' + results[0].errors[0].message);
        }

        return wo;
    }

    @AuraEnabled
    public static WorkOrder sendIcapsNumberEmail(String workOrderId) {
        WorkOrder wo = [ SELECT
                            Id, Responsible_Engineer_Contact__c, Sent_to_Engineer_Date__c,
                            Bespoke_Hardware__c, Site_Survey__c, Site_Survey_Reviewed_by_TC__c,
                            Responsible_Engineer_Contact__r.Name, Responsible_Engineer_Contact__r.Email
                        FROM WorkOrder
                        WHERE Id = :workOrderId
        ];

        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'FSL_Populate_ICAPS_number'];

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTargetObjectId(wo.Responsible_Engineer_Contact__c);
        msg.setTemplateID(et.Id);
        msg.setWhatId(wo.Id);

        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'donotreply@camlinenergy.com'];
        if (owea.size() > 0) {
            msg.setOrgWideEmailAddressId(owea[0].Id);
        }

        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        for (Attachment a : [SELECT Name, Body, BodyLength FROM Attachment WHERE ParentId = :wo.Site_Survey__c]){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
            //mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        }
        msg.setFileAttachments(fileAttachments);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {msg});

        if (results[0].success) {
            wo.Sent_to_Engineer_Date__c = Date.today();

            update wo;
        } else {
            throw new AuraHandledException('The email failed to send: ' + results[0].errors[0].message);
        }

        return wo;
    }

    @AuraEnabled
    public static WorkOrder setSiteSurveyId(String workOrderId, String siteSurveyId) {
        try {
            WorkOrder wo = [SELECT Id, Site_Survey__c, Status, AccountId FROM WorkOrder WHERE Id=:workOrderId];

            Site_Survey__c srv = new Site_Survey__c(Id=siteSurveyId, Account__c = wo.AccountId);
            update srv;

            wo.Site_Survey__c = siteSurveyId;
            wo.Status = 'Site Survey Review';
            update wo;
        }
        catch (Exception e) {
            throw new AuraHandledException('Error saving data! ' + e.getMessage());
        }

        return [SELECT Id, WorkOrderNumber, Bespoke_Hardware__c, Site_Survey__c FROM WorkOrder WHERE Id = :workOrderId];
    }

    @AuraEnabled
    public static void createTaskToReviewSiteSurvey(String workOrderId) {
        WorkOrder wo = [
                SELECT
                    Id, ServiceTerritoryId, ServiceTerritory.FS_Technical_Coordinator__c
                FROM
                    WorkOrder
                WHERE Id = :workOrderId
        ];

        if (wo.ServiceTerritoryId != NULL && wo.ServiceTerritory.FS_Technical_Coordinator__c != NULL) {
            Task t = new Task(
                    OwnerId = wo.ServiceTerritory.FS_Technical_Coordinator__c,
                    WhatId = wo.Id,
                    Subject = 'Review new Site Survey',
                    ActivityDate = Date.today() + 2,
                    Priority = 'Normal'
            );

            insert t;
        }
    }

    @AuraEnabled
    public static void saveChunk(Id parentId, String fileName, String base64Data, String contentType, Boolean isLastChunk, String randomNum) {
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        oAttachment.Description = randomNum;
        
        insert oAttachment;
        
        if(isLastChunk) {
            appendFiles(parentId, fileName, contentType, randomNum);
        }
    }
    
    @future 
    public static void appendFiles(Id parentId, String fileName, String contentType, String randomNum) {

        String body = '';
        
        List<Attachment> attachments = new List<Attachment>([
            SELECT 
                Id, Name, Body 
            FROM 
                Attachment 
            WHERE 
                ParentId = :parentId
                AND Description = :randomNum
                ORDER BY LastModifiedDate
        ]);

        for(Attachment a : attachments) {
            body += EncodingUtil.base64Encode(a.Body);
            a.Body = null;
        }
  
        Attachment att = new Attachment();
        att.ParentId = parentId;
        att.Body = EncodingUtil.base64Decode(body);
        att.ContentType = contentType;
        att.Name = fileName;
  
        insert att;
        delete attachments;
    }

    @AuraEnabled
    public static void createSalesSupportTask(String surveyId) {
        Site_Survey__c survey = [SELECT Id, Name, ICAPS_Number__c FROM Site_Survey__c WHERE Id = :surveyId];

        if (survey.ICAPS_Number__c != NULL) {
            WorkOrder wo = [
                    SELECT
                            Id, WorkOrderNumber, Site_Survey__c, Opportunity__c, Opportunity__r.Sales_Support__c
                    FROM WorkOrder
                    WHERE Site_Survey__c = :survey.Id AND WorkOrderNumber = :survey.Name
                    LIMIT 1
            ];

            Task t = new Task(
                    OwnerId = wo.Opportunity__r.Sales_Support__c,
                    WhatId = wo.Opportunity__c,
                    Subject = 'Update Product Config sheet for Work Order ' + wo.WorkOrderNumber,
                    ActivityDate = Date.today() + 2,
                    Description = 'Work Order number: ' + wo.WorkOrderNumber
            );

            insert t;
        }
    }

    @AuraEnabled
    public static Opportunity getOpportunity (String oppId) {
        return [SELECT
                    Id, Name, Account.Name, Sales_Order_Number__c, Sales_Support__r.Name,
                    (SELECT Id, Name, Product2.Name, Quantity FROM OpportunityLineItems)
                FROM Opportunity
                WHERE Id = :oppId];
    }

    @AuraEnabled
    public static void saveBespokeAvailabilityDate(String woId, Date availableDate) {
        WorkOrder wo = new WorkOrder(
            Id = woId,
            Bespoke_HW_available__c = availableDate,
            Bespoke_HW_requested__c = Date.today()
        );

        update wo;
    }

    public class FieldSetData {
        @AuraEnabled
        public String name {get; set;}

        @AuraEnabled
        public List<FieldSetField> fields { get; set; }

        public FieldSetData(Schema.FieldSet fs) {
            this.name = fs.getName();

            this.fields = new List<FieldSetField>();
            for (Schema.FieldSetMember fsm : fs.getFields()) {
                this.fields.add(new FieldSetField(fsm));
            }
        }
    }

    public class FieldSetField {
        @AuraEnabled
        public String APIName { get;set; }

        @AuraEnabled
        public Boolean DBRequired { get;set; }

        @AuraEnabled
        public Boolean Required { get;set; }

        public FieldSetField(Schema.FieldSetMember f) {
            this.DBRequired = f.DBRequired;
            this.APIName = f.fieldPath;
            this.Required = f.required;
        }
    }
}