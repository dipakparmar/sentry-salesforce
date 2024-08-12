/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
public with sharing class SentryTest {
    @IsTest
    static void Record() {
        Exception ex;

        Test.setMock(HttpCalloutMock.class, new Sentry_ApiMock());

        Sentry_TestingController controller = new Sentry_TestingController();

        Sentry_Active_Config__c config = Sentry_Active_Config__c.getOrgDefaults();
        config.IsIssueCreationDisabled__c = false;
        config.IsDebug__c = true;
        config.Sentry_Config__c = 'Test';
        config.Environment_Name__c = 'Test';
        insert config;

        Test.startTest();

        try {
            controller.triggerCapturedException();
        } catch (Exception e) {
            ex = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, ex);
    }
    
    @IsTest
    static void RecordwithCustomException() 
    {
        Exception ex;

        Test.setMock(HttpCalloutMock.class, new Sentry_ApiMock());

        Sentry_TestingController controller = new Sentry_TestingController();

        Sentry_Active_Config__c config = Sentry_Active_Config__c.getOrgDefaults();
        config.IsIssueCreationDisabled__c = false;
        config.IsDebug__c = true;
        config.Sentry_Config__c = 'Test';
        config.Environment_Name__c = 'Test';
        insert config;

        Test.startTest();
        controller.triggerCustomException();
        Test.stopTest();

        System.assertEquals(null, ex);
    }
    
    @IsTest
    static void RecordCustomExceptionWithoutSendingToSentry() 
    {
        Exception ex;

        Test.setMock(HttpCalloutMock.class, new Sentry_ApiMock());

        Sentry_TestingController controller = new Sentry_TestingController();

        Sentry_Active_Config__c config = Sentry_Active_Config__c.getOrgDefaults();
        config.IsIssueCreationDisabled__c = true;
        config.IsDebug__c = true;
        config.Sentry_Config__c = 'Test';
        config.Environment_Name__c = 'Test';
        insert config;

        Test.startTest();
        controller.triggerCustomException();
        Test.stopTest();

        System.assertEquals(null, ex);
    }
}