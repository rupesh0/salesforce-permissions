public with sharing class AppPermissionsController {
  public class AppPermissionInfo {
    public String apiName;
    public String label;
    public String description;

    public AppPermissionInfo(String apiName, String label, String description) {
      this.apiName = apiName;
      this.label = label;
      this.description = description;
    }
  }

  private static Map<String, AppPermissionInfo> appPermissionsMap;

  public static Map<String, AppPermissionInfo> getAppPermissionsMap() {
    if (appPermissionsMap != null) {
      return appPermissionsMap;
    }
    appPermissionsMap = new Map<String, AppPermissionInfo>();
    appPermissionsMap.put(
      'permissionscanaccessce',
      new AppPermissionInfo(
        'CanAccessCE',
        'Access Conversation Entries',
        'Grants users access to Conversation Entries'
      )
    );
    appPermissionsMap.put(
      'permissionsagentforceserviceagentuser',
      new AppPermissionInfo(
        'AgentforceServiceAgentUser',
        'Agentforce Service Agent User',
        'Analyze topics and perform actions as an autonomous AI service agent.'
      )
    );
    appPermissionsMap.put(
      'permissionslmoutboundmessaginguserperm',
      new AppPermissionInfo(
        'LMOutboundMessagingUserPerm',
        'Agent Initiated Outbound Messaging',
        'Initiate messaging with customers.'
      )
    );
    appPermissionsMap.put(
      'permissionsconfigurelivemessage',
      new AppPermissionInfo(
        'ConfigureLiveMessage',
        'Configure Messaging',
        'Configure Messaging settings.'
      )
    );
    appPermissionsMap.put(
      'permissionseditcasecomments',
      new AppPermissionInfo(
        'EditCaseComments',
        'Edit Case Comments',
        'Edit their own case comments but not other user\'s comments.'
      )
    );
    appPermissionsMap.put(
      'permissionslmendmessagingsessionuserperm',
      new AppPermissionInfo(
        'LMEndMessagingSessionUserPerm',
        'End Messaging Session',
        'End in-progress Messaging sessions with end users.'
      )
    );
    appPermissionsMap.put(
      'permissionsembeddedmessagingagent',
      new AppPermissionInfo(
        'EmbeddedMessagingAgent',
        'Enhanced Chat Rep',
        'Accept Enhanced Chat conversations from Omni-Channel.'
      )
    );
    appPermissionsMap.put(
      'permissionssolutionimport',
      new AppPermissionInfo(
        'SolutionImport',
        'Import Solutions',
        'Import solutions for the organization.'
      )
    );
    appPermissionsMap.put(
      'permissionscaninitiatemessagingsessions',
      new AppPermissionInfo(
        'CanInitiateMessagingSessions',
        'Initiate Messaging Sessions',
        'Initiate messaging sessions with customers by sending outbound messages in enhanced Messaging channels and Messaging for In-App.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanageagentforceserviceagent',
      new AppPermissionInfo(
        'ManageAgentforceServiceAgent',
        'Manage Agentforce Service Agents',
        'Create and update Agentforce Service agents.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagebusinesshourholidays',
      new AppPermissionInfo(
        'ManageBusinessHourHolidays',
        'Manage Business Hours Holidays',
        'Create, edit, and delete business holidays.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagecallcenters',
      new AppPermissionInfo(
        'ManageCallCenters',
        'Manage Call Centers',
        'Create, import, edit, and delete a call center configuration.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagecases',
      new AppPermissionInfo(
        'ManageCases',
        'Manage Cases',
        'Administer case settings, including Email-to-Case and mass transfer of cases.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagecategories',
      new AppPermissionInfo(
        'ManageCategories',
        'Manage Categories',
        'Define and modify solution categories settings.'
      )
    );
    appPermissionsMap.put(
      'permissionssubmitmacrosallowed',
      new AppPermissionInfo(
        'SubmitMacrosAllowed',
        'Manage Macros Users Can\'t Undo',
        'Create, update, and run macros that include irreversible instructions.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagesolutions',
      new AppPermissionInfo(
        'ManageSolutions',
        'Manage Published Solutions',
        'Create, edit, and delete publicly accessible solutions.'
      )
    );
    appPermissionsMap.put(
      'permissionsmobilemessagingagent',
      new AppPermissionInfo(
        'MobileMessagingAgent',
        'Message on Mobile',
        'Send and receive messages with the Salesforce mobile app.'
      )
    );
    appPermissionsMap.put(
      'permissionslivemessageagent',
      new AppPermissionInfo(
        'LiveMessageAgent',
        'Messaging Agent',
        'Send and receive messages through Messaging.'
      )
    );
    appPermissionsMap.put(
      'permissionsbulkmacrosallowed',
      new AppPermissionInfo(
        'BulkMacrosAllowed',
        'Run Macros on Multiple Records',
        'Run macros on multiple records at the same time.'
      )
    );
    appPermissionsMap.put(
      'permissionscansendinitialsmstoindividual',
      new AppPermissionInfo(
        'CanSendInitialSMSToIndividual',
        'Send Initial SMS Message to Individual',
        'Enable users to initiate a conversation with individuals via SMS. Without this permission, users will need to wait for individuals to initiate a conversations.'
      )
    );
    appPermissionsMap.put(
      'permissionstransferanycase',
      new AppPermissionInfo(
        'TransferAnyCase',
        'Transfer Cases',
        'Change a case\'s owner.'
      )
    );
    appPermissionsMap.put(
      'permissionscantranslatescrt2conversation',
      new AppPermissionInfo(
        'CanTranslateScrt2Conversation',
        'Translate Enhanced Conversations',
        'View and send translated messages in enhanced Messaging channels.'
      )
    );
    appPermissionsMap.put(
      'permissionscanwritewithaiscrt2conversation',
      new AppPermissionInfo(
        'CanWriteWithAiScrt2Conversation',
        'Write with AI',
        'Let service reps use generative AI to fine-tune their messages to customers in Enhanced Chat and Enhanced Messaging.'
      )
    );
    appPermissionsMap.put(
      'permissionsdeletesalesforcefiles',
      new AppPermissionInfo(
        'DeleteSalesforceFiles',
        'Delete Salesforce Files',
        'Allow Users to delete accessible Salesforce Files.'
      )
    );
    appPermissionsMap.put(
      'permissionsdownloadmaliciousfiles',
      new AppPermissionInfo(
        'DownloadMaliciousFiles',
        'Download Malicious Files',
        'Download files that contain viruses or malware. Users can view files from Files Home.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagecontentpermissions',
      new AppPermissionInfo(
        'ManageContentPermissions',
        'Manage Content Permissions',
        'Create, edit, and delete library permissions in Salesforce CRM Content.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagecontentproperties',
      new AppPermissionInfo(
        'ManageContentProperties',
        'Manage Content Properties',
        'Create, edit, and delete custom fields in Salesforce CRM Content.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagemaliciousfiles',
      new AppPermissionInfo(
        'ManageMaliciousFiles',
        'Manage Malicious Files',
        'View, download, and delete files that contain viruses or malware. Users can view these files from Files Home.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagecontenttypes',
      new AppPermissionInfo(
        'ManageContentTypes',
        'Manage record types and layouts for Files',
        'Create, edit, and delete content types in Salesforce CRM Content..'
      )
    );
    appPermissionsMap.put(
      'permissionscontentadministrator',
      new AppPermissionInfo(
        'ContentAdministrator',
        'Manage Salesforce CRM Content',
        'Create, edit, and delete libraries and library memberships.'
      )
    );
    appPermissionsMap.put(
      'permissionsqueryallfiles',
      new AppPermissionInfo(
        'QueryAllFiles',
        'Query All Files',
        'Allows View All Data users to SOQL query all files in the org.'
      )
    );
    appPermissionsMap.put(
      'permissionsquerynonvetoedfiles',
      new AppPermissionInfo(
        'QueryNonVetoedFiles',
        'Query Non Vetoed Files',
        'Allows Data Cloud users to SOQL query all non vetoed files in the org.'
      )
    );
    appPermissionsMap.put(
      'permissionsviewcontent',
      new AppPermissionInfo(
        'ViewContent',
        'View Content in Portals',
        'View Salesforce CRM Content from a portal.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanagecontenttaxonomy',
      new AppPermissionInfo(
        'ManageContentTaxonomy',
        'Manage Content Taxonomy',
        'Allow users to create, edit, and delete content taxonomy in the UI, and modify objects with Salesforce APIs.'
      )
    );
    appPermissionsMap.put(
      'permissionsviewcontenttaxonomy',
      new AppPermissionInfo(
        'ViewContentTaxonomy',
        'View Content Taxonomy',
        'Allow users read-only access to content taxonomy in the UI, and objects with Salesforce APIs.'
      )
    );
    appPermissionsMap.put(
      'permissionsaccessorchestrationobjects',
      new AppPermissionInfo(
        'AccessOrchestrationObjects',
        'Access Orchestration Objects',
        'In this org, gives mobile users access to FlowOrchestration and associated objects, which allows them to create, read, and update records in Orchestration flows. This permission is for mobile offline use only.'
      )
    );
    appPermissionsMap.put(
      'permissionsactivatesystemmodeflows',
      new AppPermissionInfo(
        'ActivateSystemModeFlows',
        'Enable System Mode Flow Activation',
        'Allows a user to activate system flows.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanageinteraction',
      new AppPermissionInfo(
        'ManageInteraction',
        'Manage Flow',
        'Allow users to view, create, edit, delete, and activate all flows and flow types in Lightning Experience apps and Setup.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanageorchestrationruns',
      new AppPermissionInfo(
        'ManageOrchestrationRuns',
        'Manage Orchestration Runs',
        'Cancel, debug, suspend, and resume orchestration runs.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanageorchinstsandworkitems',
      new AppPermissionInfo(
        'ManageOrchInstsAndWorkItems',
        'Manage Orchestration Runs and Work Items',
        'Cancel, debug, suspend, and resume orchestration runs and reassign orchestration work items.'
      )
    );
    appPermissionsMap.put(
      'permissionsreassignorchestrationworkitems',
      new AppPermissionInfo(
        'ReassignOrchestrationWorkItems',
        'Reassign Orchestration Work Items',
        'Reassign orchestration work items.'
      )
    );
    appPermissionsMap.put(
      'permissionsrunflow',
      new AppPermissionInfo(
        'RunFlow',
        'Run Flows',
        'In this org, run any active flow. In Experience Builder sites, run any active flow that\'s distributed with the Flow Lightning component.'
      )
    );
    appPermissionsMap.put(
      'permissionsviewflowusageandfloweventdata',
      new AppPermissionInfo(
        'ViewFlowUsageAndFlowEventData',
        'View Flow Usage and Flow Event Data',
        'Unsupported. Use the View Setup and Configuration permission to let users access flow usage data and flow standard platform event data.'
      )
    );
    appPermissionsMap.put(
      'permissionsvieworchestrationsinautomapp',
      new AppPermissionInfo(
        'ViewOrchestrationsInAutomApp',
        'View Orchestrations in Automation App',
        'In Lightning Experience apps, allow users to view all orchestration runs, orchestration run-related details, and orchestration definitions, regardless of ownership or sharing settings. Only users who also have the Manage Flow permission can edit an orchestration definition or cancel, debug, suspend, or resume an orchestration run.'
      )
    );
    appPermissionsMap.put(
      'permissionsallowviewknowledge',
      new AppPermissionInfo(
        'AllowViewKnowledge',
        'Allow View Knowledge',
        'Allow user to view knowledge articles'
      )
    );
    appPermissionsMap.put(
      'permissionsallowuniversalsearch',
      new AppPermissionInfo(
        'AllowUniversalSearch',
        'Knowledge One',
        'Replaces the Articles tab with the Knowledge tab.'
      )
    );
    appPermissionsMap.put(
      'permissionseditknowledge',
      new AppPermissionInfo(
        'EditKnowledge',
        'Manage Articles',
        'Create, edit, assign, publish, delete, and archive Salesforce Knowledge articles.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanageknowledgeimportexport',
      new AppPermissionInfo(
        'ManageKnowledgeImportExport',
        'Manage Knowledge Article Import/Export',
        'Allows user to manage all the Knowledge Article Import/Export'
      )
    );
    appPermissionsMap.put(
      'permissionsmanageknowledge',
      new AppPermissionInfo(
        'ManageKnowledge',
        'Manage Salesforce Knowledge',
        'Manage Salesforce Knowledge settings, and create, edit, and delete article types.'
      )
    );
    appPermissionsMap.put(
      'permissionsshareinternalarticles',
      new AppPermissionInfo(
        'ShareInternalArticles',
        'Share internal Knowledge articles externally',
        'Allow user to share internal Knowledge articles externally'
      )
    );
    appPermissionsMap.put(
      'permissionsiprestrictrequests',
      new AppPermissionInfo(
        'IPRestrictRequests',
        'IP Restrict Requests',
        'Restrict what IP addresses can access in the PRM Portal.'
      )
    );
    appPermissionsMap.put(
      'permissionsprmextintprtnradminuser',
      new AppPermissionInfo(
        'PrmExtIntPrtnrAdminUser',
        'Set Up Partner Connect for a Partner Org',
        'Access the Partner Connect for Partners page in Setup, where partner admins can respond to vendor admins\' requests to securely integrate leads and opportunities across the two companies\' Salesforce orgs.'
      )
    );
    appPermissionsMap.put(
      'permissionscontactinspectoruser',
      new AppPermissionInfo(
        'ContactInspectorUser',
        'Access Contact Intelligence View in Partner Sites',
        'Gives partner users access to Contact Intelligence View.'
      )
    );
    appPermissionsMap.put(
      'permissionsleadinspectoruser',
      new AppPermissionInfo(
        'LeadInspectorUser',
        'Access Lead Intelligence View in Partner Sites',
        'Gives partner users access to Lead Intelligence View.'
      )
    );
    appPermissionsMap.put(
      'permissionsviewdataassessment',
      new AppPermissionInfo(
        'ViewDataAssessment',
        'Access to view Data Assessment',
        'Access to view Data Assessment. Data Assessment provides a summary of the state and quality of the org\'s CRM data'
      )
    );
    appPermissionsMap.put(
      'permissionsactivatecontract',
      new AppPermissionInfo(
        'ActivateContract',
        'Activate Contracts',
        'Change contract status to Activated.'
      )
    );
    appPermissionsMap.put(
      'permissionsactivateorder',
      new AppPermissionInfo(
        'ActivateOrder',
        'Activate Orders',
        'Change order status to Activated.'
      )
    );
    appPermissionsMap.put(
      'permissionssalesforceiqinternal',
      new AppPermissionInfo(
        'SalesforceIQInternal',
        'Allows the Cloud Integration User to perform SalesforceIQ internal operations',
        'Allows the Cloud Integration User to perform SalesforceIQ internal operations'
      )
    );
    appPermissionsMap.put(
      'permissionscampaigninfluence2',
      new AppPermissionInfo(
        'CampaignInfluence2',
        'Campaign Influence',
        'Enable Access to Customizable Campaign Influence'
      )
    );
    appPermissionsMap.put(
      'permissionsconvertleads',
      new AppPermissionInfo(
        'ConvertLeads',
        'Convert Leads',
        'Convert leads into accounts, contacts, and opportunities.'
      )
    );
    appPermissionsMap.put(
      'permissionsdeleteactivatedcontract',
      new AppPermissionInfo(
        'DeleteActivatedContract',
        'Delete Activated Contracts',
        'Delete contracts, regardless of their status.'
      )
    );
    appPermissionsMap.put(
      'permissionseditactivatedorders',
      new AppPermissionInfo(
        'EditActivatedOrders',
        'Edit Activated Orders',
        'Edit an order record once it is activated.'
      )
    );
    appPermissionsMap.put(
      'permissionseditopplineitemunitprice',
      new AppPermissionInfo(
        'EditOppLineItemUnitPrice',
        'Edit Opportunity Product Sales Price',
        'Change the sales price on opportunity line items.'
      )
    );
    appPermissionsMap.put(
      'permissionsimportleads',
      new AppPermissionInfo(
        'ImportLeads',
        'Import Leads',
        'Import leads and update campaign history.'
      )
    );
    appPermissionsMap.put(
      'permissionsimportpersonal',
      new AppPermissionInfo(
        'ImportPersonal',
        'Import Personal Contacts',
        'Import personal accounts and contacts.'
      )
    );
    appPermissionsMap.put(
      'permissionsuseinboxschedulingonbehalfof',
      new AppPermissionInfo(
        'UseInboxSchedulingOnBehalfOf',
        'Inbox Scheduling Proxy User',
        'Allow access to inbox scheduling on behalf of another user.'
      )
    );
    appPermissionsMap.put(
      'permissionsmanageleads',
      new AppPermissionInfo(
        'ManageLeads',
        'Manage Leads',
        'Change the status of multiple leads in a list view.'
      )
    );
    appPermissionsMap.put(
      'permissionssalesconsole',
      new AppPermissionInfo(
        'SalesConsole',
        'Sales Console',
        'Allow users to access Sales Console.'
      )
    );
    appPermissionsMap.put(
      'permissionssendsitrequests',
      new AppPermissionInfo(
        'SendSitRequests',
        'Send Stay-in-Touch Requests',
        'Send Stay-in-Touch update emails.'
      )
    );
    appPermissionsMap.put(
      'permissionstransferanylead',
      new AppPermissionInfo(
        'TransferAnyLead',
        'Transfer Leads',
        'Change a lead\'s owner.'
      )
    );
    appPermissionsMap.put(
      'permissionsautomaticactivitycapture',
      new AppPermissionInfo(
        'AutomaticActivityCapture',
        'Use Einstein Activity Capture',
        'Keep data between Salesforce and email and calendar applications up to date.'
      )
    );
    appPermissionsMap.put(
      'permissionsstdautomaticactivitycapture',
      new AppPermissionInfo(
        'StdAutomaticActivityCapture',
        'Use Einstein Activity Capture Standard',
        'Keep data between Salesforce and email and calendar applications up to date.'
      )
    );
    appPermissionsMap.put(
      'permissionssalesforceiqinbox',
      new AppPermissionInfo(
        'SalesforceIQInbox',
        'Use Inbox',
        'Use all Inbox features.'
      )
    );
    appPermissionsMap.put(
      'permissionsuseteamreassignwizards',
      new AppPermissionInfo(
        'UseTeamReassignWizards',
        'Use Team Reassignment Wizards',
        'Mass reassign account team and opportunity team members.'
      )
    );
    appPermissionsMap.put(
      'permissionsviewallactivities',
      new AppPermissionInfo(
        'ViewAllActivities',
        'View All Activities',
        'View all activity data irrespective of sharing rules.'
      )
    );
    appPermissionsMap.put(
      'permissionsallowvieweditconvertedleads',
      new AppPermissionInfo(
        'AllowViewEditConvertedLeads',
        'View and Edit Converted Leads',
        'View and edit converted lead records.'
      )
    );
    return appPermissionsMap;
  }

  @AuraEnabled(cacheable=true)
  public static List<AppPermissionWrapper> getAppPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<AppPermissionWrapper> enabledPermissions = new List<AppPermissionWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );

      if (unifiedPermissionSetIds.isEmpty()) {
        return enabledPermissions;
      }

      Map<String, Schema.SObjectField> psFields = Schema.sObjectType.PermissionSet.fields.getMap();
      Map<String, AppPermissionInfo> allAppPerms = getAppPermissionsMap();

      List<String> validQueryFields = new List<String>();
      for (String fieldLower : allAppPerms.keySet()) {
        if (psFields.containsKey(fieldLower)) {
          validQueryFields.add(
            psFields.get(fieldLower).getDescribe().getName()
          );
        }
      }

      if (validQueryFields.isEmpty()) {
        return enabledPermissions;
      }

      String soql =
        'SELECT Id, ' +
        String.join(validQueryFields, ', ') +
        ' FROM PermissionSet WHERE Id IN :unifiedPermissionSetIds';

      List<PermissionSet> permSets = Database.query(soql);
      Set<String> enabledFieldNames = new Set<String>();

      for (PermissionSet ps : permSets) {
        for (String fieldName : validQueryFields) {
          Boolean isGranted = (Boolean) ps.get(fieldName);
          if (isGranted == true) {
            enabledFieldNames.add(fieldName.toLowerCase());
          }
        }
      }

      for (String fieldLower : validQueryFields) {
        String key = fieldLower.toLowerCase();
        if (enabledFieldNames.contains(key)) {
          AppPermissionInfo info = allAppPerms.get(key);
          enabledPermissions.add(
            new AppPermissionWrapper(info.apiName, info.label, info.description)
          );
        }
      }

      return enabledPermissions;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class AppPermissionWrapper {
    @AuraEnabled
    public String apiName { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String description { get; set; }

    public AppPermissionWrapper(
      String apiName,
      String label,
      String description
    ) {
      this.apiName = apiName;
      this.label = label;
      this.description = description;
    }
  }
}
