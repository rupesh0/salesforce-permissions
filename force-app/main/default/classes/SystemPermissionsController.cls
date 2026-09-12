public with sharing class SystemPermissionsController {
  private static Map<String, String> descriptionsMap;

  private static Map<String, String> getDescriptionsMap() {
    if (descriptionsMap != null) {
      return descriptionsMap;
    }
    descriptionsMap = new Map<String, String>();
    descriptionsMap.put(
      'permissionsacceptinboundbundling',
      'Allow your bundles to include packages from other Dev Hub orgs.'
    );
    descriptionsMap.put(
      'permissionsacceptriskforproblems',
      'Allows users to accept risk for problems.'
    );
    descriptionsMap.put(
      'permissionsfscarcgraphcommunityuser',
      'Grants access to ARC Relationship Graph, ARC Highlights Panel, and ARC Record Details Lightning components to partner users.'
    );
    descriptionsMap.put(
      'permissionsactivitiesaccess',
      'Access tasks, events, calendar, and email.'
    );
    descriptionsMap.put(
      'permissionsaccessbankingrelationshipassistance',
      'Enable Banking Relationship Assistance.'
    );
    descriptionsMap.put(
      'permissionsaccessbankingserviceagent',
      'Grants users access to Banking Service Assistance AI agent.'
    );
    descriptionsMap.put(
      'permissionsaccesscommandcenter',
      'Get access to the Command Center resources.'
    );
    descriptionsMap.put(
      'permissionslifecyclemanagementapiuser',
      'Use APIs to manage lifecycle-managed assets.'
    );
    descriptionsMap.put(
      'permissionscustommobileappsaccess',
      'Allow user to run custom mobile apps.'
    );
    descriptionsMap.put(
      'permissionsaccesscontentbuilder',
      'Create and manage email templates and content in a drag-and-drop builder.'
    );
    descriptionsMap.put(
      'permissionsaccesscmc',
      'Access pages and dashboards available in Experience Management.'
    );
    descriptionsMap.put('permissionscontentworkspaces', 'Access libraries.');
    descriptionsMap.put(
      'permissionspersonalizationplatform',
      'Access the Personalization Platform and its entities.'
    );
    descriptionsMap.put(
      'permissionsaccesspolicyagent',
      'Enable insurance service assistance agent features.'
    );
    descriptionsMap.put(
      'permissionsaccessserviceeinstein',
      'Grants users the access to AI-powered copilot actions for capturing service process requests.'
    );
    descriptionsMap.put(
      'permissionsuserouting',
      'Access the Fulfillment Order routing APIs.'
    );
    descriptionsMap.put(
      'permissionsappframeworkmanageapp',
      'Allows access to create, update, and manage apps from templates, analytics, data, and other assets.'
    );
    descriptionsMap.put(
      'permissionsappframeworkmanagetemplate',
      'Allows access to create, update, and manage app templates.'
    );
    descriptionsMap.put(
      'permissionsviewonlyembeddedappuser',
      'View apps based on View-Only License.'
    );
    descriptionsMap.put(
      'permissionsappframeworkviewapp',
      'Allows access to app, analytics, data, and other assets that are created from the template framework.'
    );
    descriptionsMap.put(
      'permissionstracexdsqueries',
      'Access the Tracer tool for testing queries to External Data Sources.'
    );
    descriptionsMap.put(
      'permissionscandoactasuser',
      'Gives the mapped user ability to access core data in a multi org use case that use C2C Act As User JWT for authN. (Note: This permission is for testing purposes only and should be used with CloudToCloudPilotFeatures)'
    );
    descriptionsMap.put(
      'permissionsuseaddorderitemsummary',
      'Add additional items to an order summary.'
    );
    descriptionsMap.put(
      'permissionsaddanalyticsremoteconnections',
      'Add connections to replicate external data.'
    );
    descriptionsMap.put(
      'permissionsuseaddadjustment',
      'Add order item summary level adjustments.'
    );
    descriptionsMap.put(
      'permissionsadddirectmessagemembers',
      'Lets a user add others to direct messages the user is in.'
    );
    descriptionsMap.put(
      'permissionsaddwavenotificationrecipients',
      'Specify recipients of email and Slack notifications from CRM Analytics dashboard widgets. In email, all recipient addresses appear in the "to:" field, and recipients can see each other\'s email addresses regardless of User Sharing settings.'
    );
    descriptionsMap.put(
      'permissionsterritoryoperations',
      'Prerequisite user permission for a user to manage a territory branch.'
    );
    descriptionsMap.put(
      'permissionsadvancedcsvdataimportuser',
      'Advanced Csv Data Import User Permission'
    );
    descriptionsMap.put(
      'permissionsmeetingengagementuser',
      'Grants user access to Agentforce Meeting Concierge features.'
    );
    descriptionsMap.put(
      'permissionsuseweblink',
      'Unsupported. Use the page layout editor to customize which actions show up in Salesforce and in the Salesforce mobile app.'
    );
    descriptionsMap.put(
      'permissionsenableipfsupload',
      'Let the user upload blockchain data'
    );
    descriptionsMap.put(
      'permissionsclientsecretrotation',
      'Allows a user to rotate a connected app\'s consumer key and secret.'
    );
    descriptionsMap.put(
      'permissionschattercomposeuicodesnippet',
      'Allow users to post code snippets to Chatter from the UI where available.'
    );
    descriptionsMap.put(
      'permissionscombauthandcappayments',
      'Authorize and capture payments for a sale transaction.'
    );
    descriptionsMap.put(
      'permissionslistemailsend',
      'Allow users to create, edit and send List Emails'
    );
    descriptionsMap.put(
      'permissionsmanageapinamedqueries',
      'Allows users to create, read, update and delete Named Query records.'
    );
    descriptionsMap.put(
      'permissionsmanagenamedcredentials',
      'Allow users to modify Named Credentials and External Credentials through the Metadata, Tooling, and Connect APIs.'
    );
    descriptionsMap.put(
      'permissionsviewapinamedqueries',
      'Allows users to view Named Query records.'
    );
    descriptionsMap.put(
      'permissionsreadconfigurationiteminformation',
      'Allows user to read CMDB associations details.'
    );
    descriptionsMap.put(
      'permissionsmanagecdpmlmodels',
      'Allows users to create, update, and delete models in Einstein Studio.'
    );
    descriptionsMap.put(
      'permissionsviewmlmodels',
      'Allow API read only access for Unified Model Tree for an AI Application, namely MLModels, MLModelFactors, MLModelMetrics, MLModelFactorComponents'
    );
    descriptionsMap.put(
      'permissionsprivacydataaccess',
      'Allow user to access privacy data.'
    );
    descriptionsMap.put(
      'permissionsmanageexternalconnections',
      'Allow users to modify Private Connections through the Metadata, Tooling, and Connect APIs.'
    );
    descriptionsMap.put(
      'permissionsallowobjectdetectiontraining',
      'Allows user to train and generate models for Object Detection.'
    );
    descriptionsMap.put(
      'permissionsallowobjectdetection',
      'Allows a user to use Object Detection for prediction.'
    );
    descriptionsMap.put(
      'permissionsapexrestservices',
      'Allow access to Apex REST services'
    );
    descriptionsMap.put(
      'permissionsapienabled',
      'Access any Salesforce.com API.'
    );
    descriptionsMap.put(
      'permissionsapiuseronly',
      'Access Salesforce.com only through a Salesforce.com API.'
    );
    descriptionsMap.put(
      'permissionsapprovaladmin',
      'Cancel or recall in-progress approval submissions and reassign open work items or complete them for other users.'
    );
    descriptionsMap.put(
      'permissionsapprovaldesigner',
      'Create, edit, delete, and activate flow approval processes.'
    );
    descriptionsMap.put(
      'permissionscanapproveuninstalledapps',
      'Approve access to connected apps that aren&#8217;t installed in this org.'
    );
    descriptionsMap.put(
      'permissionsassigntopics',
      'Assign existing topics to Chatter feed items. Remove topics from Chatter feed items.'
    );
    descriptionsMap.put(
      'permissionsassocchgrqstandprob',
      'Allows users to add and remove associations for problems and change requests.'
    );
    descriptionsMap.put(
      'permissionsassocincandchgrqst',
      'Allows users to add and remove associations for incidents and change requests.'
    );
    descriptionsMap.put(
      'permissionsassocincandprob',
      'Allows users to add and remove associations for incidents and problems.'
    );
    descriptionsMap.put(
      'permissionsassocrelandchgrqst',
      'Allows users to add and remove associations for change requests and releases.'
    );
    descriptionsMap.put(
      'permissionsassocrelandinc',
      'Allows users to add and remove associations for incidents and releases.'
    );
    descriptionsMap.put(
      'permissionsassocrelandprob',
      'Allows users to add and remove associations for problems and releases.'
    );
    descriptionsMap.put(
      'permissionsattributionmodeluser',
      'Allows user to access the Attribution Model'
    );
    descriptionsMap.put(
      'permissionsauthorapex',
      'Create Apex classes and triggers.'
    );
    descriptionsMap.put('permissionsauthorizepayments', 'Authorize payments.');
    descriptionsMap.put(
      'permissionssimplecsvdataimportuser',
      'Basic Csv Data Import User Permission'
    );
    descriptionsMap.put(
      'permissionsbulkapiharddelete',
      'Delete records in the Bulk API without storing them in the Recycle Bin.'
    );
    descriptionsMap.put(
      'permissionscanapprovefeedpost',
      'Lets Chatter users control the visibility of content to other Chatter users by updating the status of a feed item or comment from pending review to published or from published to pending review.'
    );
    descriptionsMap.put(
      'permissionsusecancancelinprogresschange',
      'Can cancel Order Management in-progress async calls.'
    );
    descriptionsMap.put(
      'permissionsuseorderitemsummarycancel',
      'Cancel order item summaries.'
    );
    descriptionsMap.put(
      'permissionscaptureandreversepayments',
      'Capture and reverse authorized payments.'
    );
    descriptionsMap.put(
      'permissionschangedashboardcolors',
      'Choose dashboard color theme and palette.'
    );
    descriptionsMap.put(
      'permissionschatterinternaluser',
      'Use all Chatter features.'
    );
    descriptionsMap.put(
      'permissionscloseconversations',
      'Close conversation threads in profile, group, and topic Chatter feeds in Experience Cloud sites.'
    );
    descriptionsMap.put(
      'permissionsuserinteractioninsights',
      'Allows collection of user engagement data to calculate insights.'
    );
    descriptionsMap.put(
      'permissionsconfigcustomrecs',
      'Add custom recommendations in the Chatter feed, motivating users to get engaged and take action.'
    );
    descriptionsMap.put(
      'permissionsconfiguredataspacescope',
      'Grants users access to view, create, edit, and delete a restriction rule for a Dataspace Scope'
    );
    descriptionsMap.put(
      'permissionsconnectorgtoenvironmenthub',
      'Allows a user to connect this organization to an Environment Hub.'
    );
    descriptionsMap.put(
      'permissionsmanagehubconnections',
      'Allows a user to connect the org to Customer 360 Data Manager.'
    );
    descriptionsMap.put(
      'permissionsmanagec360aconnections',
      'Allows a user to connect the org to Data Cloud.'
    );
    descriptionsMap.put(
      'permissionsexternalclientappdeveloper',
      'Create, edit, and delete External Client Apps.'
    );
    descriptionsMap.put(
      'permissionsaicreateinsightobjects',
      'Create objects associated with AI record insights, including the insight, value, reason, and feedback.'
    );
    descriptionsMap.put(
      'permissionscreatecustomizedashboards',
      'Create, edit, and delete dashboards in personal folders.'
    );
    descriptionsMap.put(
      'permissionscreatecustomizefilters',
      'Create list views; modify and delete own list views.'
    );
    descriptionsMap.put(
      'permissionscreatecustomizereports',
      'Create, edit, and delete reports in personal folders.'
    );
    descriptionsMap.put(
      'permissionsinsightsappdashboardeditor',
      'Create and Edit CRM Analytics Dashboards.'
    );
    descriptionsMap.put(
      'permissionschatterowngroups',
      'Create and own new Chatter groups.'
    );
    descriptionsMap.put(
      'permissionsmanagenetworks',
      'Create Experience Cloud sites, manage settings, membership, login and registration, branding, and associated Site.com site.'
    );
    descriptionsMap.put(
      'permissionspackaging2',
      'Create and update these packages using the command-line interface.'
    );
    descriptionsMap.put(
      'permissionscreatepackaging',
      'Create packages that can be distributed through AppExchange.'
    );
    descriptionsMap.put(
      'permissionsb2bmarketinganalyticsuser',
      'View and create B2B Marketing Analytics apps.'
    );
    descriptionsMap.put(
      'permissionsmanagecms',
      'Create Workspaces and Channels in Salesforce CMS.'
    );
    descriptionsMap.put(
      'permissionsdistributefromperswksp',
      'Create content delivery links to share files that aren\'t managed by a library. To let a user create content deliveries for files in a library, enable Deliver Content for that user in the library.'
    );
    descriptionsMap.put(
      'permissionsusecreatecreditmemo',
      'Create credit memos.'
    );
    descriptionsMap.put(
      'permissionsinsightscreateapplication',
      'Create CRM Analytics Apps.'
    );
    descriptionsMap.put(
      'permissionscreatedashboardfolders',
      'Create dashboard folders and manage these folders if sharing rights allow.'
    );
    descriptionsMap.put(
      'permissionscreateltngtempfolder',
      'Create Folders for Lightning Email Templates'
    );
    descriptionsMap.put('permissionscreateworkspaces', 'Create libraries.');
    descriptionsMap.put(
      'permissionsusecreateordersummary',
      'Create order summaries by using APIs.'
    );
    descriptionsMap.put(
      'permissionschatterfilelink',
      'Let users create links to share files externally. Unlike content deliveries, public links can\'t be password protected. To let a user create links to files in a library, enable Deliver Content for that user in the library.'
    );
    descriptionsMap.put(
      'permissionscreatereportfolders',
      'Create report folders and manage these folders if sharing rights allow.'
    );
    descriptionsMap.put(
      'permissionscreatetopics',
      'Create new Chatter topics by assigning them to Chatter feed items.'
    );
    descriptionsMap.put(
      'permissionscustomappsonfsmobile',
      'Enable Custom Applications in the Field Service mobile app. This requires enabling the Lightning SDK for Field Service Mobile org setting or the Lightning user permission.'
    );
    descriptionsMap.put(
      'permissionscustomizeapplication',
      'Customize the organization using App Setup menu options.'
    );
    descriptionsMap.put(
      'permissionspersonalizedfinanceuseraccess',
      'Data Cloud FlexCards for Financial Services Cloud.'
    );
    descriptionsMap.put(
      'permissionsdeletechangerequest',
      'Gives users delete access for Change Request records.'
    );
    descriptionsMap.put(
      'permissionsdeletecrmemoandinvoice',
      'Allows a user to delete Credit Memo and Invoice records.'
    );
    descriptionsMap.put(
      'permissionsdeleteincident',
      'Gives users delete access for Incident records.'
    );
    descriptionsMap.put(
      'permissionsdeleteproblem',
      'Gives users delete access for Problem records.'
    );
    descriptionsMap.put(
      'permissionspackaging2delete',
      'Delete packages and package versions.'
    );
    descriptionsMap.put(
      'permissionsdeletetopics',
      'Delete Chatter topics and remove all corresponding topic assignments from Chatter feed items.'
    );
    descriptionsMap.put(
      'permissionscaneditprompts',
      'Create, edit, and delete prompts and walkthroughs in Lightning Experience.'
    );
    descriptionsMap.put(
      'permissionsdigitallendingadminuser',
      'Allow user access Digital Lending admin specific features'
    );
    descriptionsMap.put(
      'permissionsdigitallendingeditreadonly',
      'Grant access to edit Party related records when Read Only is selected on the corresponding Party record and Turn on read only digital lending party related records.'
    );
    descriptionsMap.put(
      'permissionsdigitallendinguser',
      'Grants user to access Digital Lending specific features'
    );
    descriptionsMap.put(
      'permissionsdigitallendingworkbench',
      'Grants access to digital lending workbench features'
    );
    descriptionsMap.put(
      'permissionsaccesstodisputemanagement',
      'Grants users the access to Dispute Management Data'
    );
    descriptionsMap.put(
      'permissionsinstallpackaging',
      'Install or uninstall AppExchange packages as system administrators.'
    );
    descriptionsMap.put(
      'permissionswavetabulardownload',
      'Download data in tabular format from the CRM Analytics user interface. If the Subscribe to CRM Analytics Assets permission is granted, downloaded table data can be attached to subscription emails.'
    );
    descriptionsMap.put(
      'permissionsdownloadpackageversionzips',
      'Download zip files containing metadata for a previously published package version.'
    );
    descriptionsMap.put(
      'permissionscanusenewdashboardbuilder',
      'Create, edit, and delete dashboards through the drag-and-drop dashboard builder interface.'
    );
    descriptionsMap.put(
      'permissionsinsightsappelteditor',
      'Edit CRM Analytics dataflows and view errors related to them.'
    );
    descriptionsMap.put(
      'permissionscaneditdatapreprecipe',
      'Create and edit dataset recipes using source datasets.'
    );
    descriptionsMap.put(
      'permissionseditevent',
      'Create, edit, and delete events.'
    );
    descriptionsMap.put(
      'permissionsedithtmltemplates',
      'Edit Classic HTML Email Templates.'
    );
    descriptionsMap.put(
      'permissionseditmydashboards',
      'Edit, move, save, and delete user\'s own dashboards in shared folders.'
    );
    descriptionsMap.put(
      'permissionschattereditownpost',
      'Allow users to edit their own Chatter feed items.'
    );
    descriptionsMap.put(
      'permissionseditmyreports',
      'Edit, move, save, and delete user\'s own reports in shared folders.'
    );
    descriptionsMap.put(
      'permissionschattereditownrecordpost',
      'Allow users to edit Chatter feed items they manage.'
    );
    descriptionsMap.put(
      'permissionseditreadonlyfields',
      'Edit fields that are read only due to page layouts or field-level security.'
    );
    descriptionsMap.put(
      'permissionseditrepricing',
      'Allow the user to edit repricing information such as webstore, integration, and other repricing setup.'
    );
    descriptionsMap.put(
      'permissionsedittask',
      'Create, edit, and delete tasks.'
    );
    descriptionsMap.put(
      'permissionsedittopics',
      'Edit topic names and descriptions.'
    );
    descriptionsMap.put(
      'permissionsusemysearch',
      'Enable Einstein Search and show recommended search results.'
    );
    descriptionsMap.put(
      'permissionsallowemailic',
      'Provides an option to use email to verify identity, even if the user has a verified phone number.'
    );
    descriptionsMap.put(
      'permissionsuserhasalmsimpledeployaccess',
      'Enable ALM Simple Deploy User Permission'
    );
    descriptionsMap.put(
      'permissionsenablebctransactionpolling',
      'Enable blockchain transaction polling API'
    );
    descriptionsMap.put(
      'permissionsheadlesscmsaccess',
      'Enable Salesforce CMS integration with any endpoint and allow user access to Salesforce CMS data.'
    );
    descriptionsMap.put(
      'permissionsappointmentbookinguseraccess',
      'Enables the Appointment Booking feature.'
    );
    descriptionsMap.put(
      'permissionsworkdotcomuserperm',
      'Allow WDC only users to access WDC functionality.'
    );
    descriptionsMap.put(
      'permissionsworkcalibrationuser',
      'Allow WDC users to access WDC Calibration functionality.'
    );
    descriptionsMap.put(
      'permissionsengagementconfiguser',
      'Allows user to access the Engagement Config'
    );
    descriptionsMap.put(
      'permissionsuseorderitemsummaryreturn',
      'Execute blind returns.'
    );
    descriptionsMap.put('permissionsuseensurefunds', 'Execute ensure funds.');
    descriptionsMap.put(
      'permissionstransactionsecurityexempt',
      'Prevent a user\'s actions from triggering Transaction Security Policies. Be careful in delegating this permission. Assign it only to essential users whose actions, such as automated or bulk API calls, are likely to block critical business processes.'
    );
    descriptionsMap.put(
      'permissionsexportreport',
      'Use Export Details and Printable View to export reports.'
    );
    descriptionsMap.put(
      'permissionsschedulingfacilitymanager',
      'Allows users to create queues and queued parties.'
    );
    descriptionsMap.put(
      'permissionscontenthubuser',
      'Access cloud-based external content sources, such as SharePoint Online.'
    );
    descriptionsMap.put(
      'permissionsaccesswealthadvisoragent',
      'Enable financial advisor assistance agent features.'
    );
    descriptionsMap.put(
      'permissionsgiverecognitionbadge',
      'Lets members give recognition badges to other members.'
    );
    descriptionsMap.put(
      'permissionsmngbenverfforassistiveagnt',
      'Gives AI agents access to the objects and fields required to reverify benefits.'
    );
    descriptionsMap.put(
      'permissionsuseteamsforemployee',
      'Gives employee users the ability to use Microsoft Teams to manage and resolve IT issues and service requests.'
    );
    descriptionsMap.put(
      'permissionsgrantoutboundbundling',
      'Authorize other Dev Hub orgs to include your packages in their bundles.'
    );
    descriptionsMap.put(
      'permissionsaccesssfdrive',
      'Grant users permission to SfDrive'
    );
    descriptionsMap.put(
      'permissionspreventclassicexperience',
      'Always use Lightning Experience; removes the Switcher so it\'s not possible to switch to Salesforce Classic.'
    );
    descriptionsMap.put(
      'permissionshidereadbylist',
      'Increases privacy in a private Chatter group by hiding the count and names of those who view its posts.'
    );
    descriptionsMap.put(
      'permissionsimportcustomobjects',
      'Allows non-admin users to import Custom Objects using Data Import Wizard.'
    );
    descriptionsMap.put(
      'permissionscaninsertfeedsystemfields',
      'Set the author or creation date for a Chatter post or comment.'
    );
    descriptionsMap.put(
      'permissionsuseassistantdialog',
      'Show instant results and record previews from the global search box.'
    );
    descriptionsMap.put(
      'permissionsintegrationintelligenceuser',
      'Grant users access to Integration Intelligence and MuleSoft Observability features'
    );
    descriptionsMap.put(
      'permissionschatterinviteexternalusers',
      'Invite Customers To Chatter'
    );
    descriptionsMap.put(
      'permissionslightningscheduleruseraccess',
      'Let a user be included in appointments in Salesforce Scheduler.'
    );
    descriptionsMap.put(
      'permissionslobbymanagementuseraccess',
      'Let greeters access the Lobby Management tab.'
    );
    descriptionsMap.put(
      'permissionslightningconsoleallowedforuser',
      'Gives the user access to Lightning console apps.'
    );
    descriptionsMap.put(
      'permissionslightningexperienceuser',
      'Access Lightning Experience and switch between Lightning Experience and Salesforce Classic.'
    );
    descriptionsMap.put(
      'permissionsallowlightninglogin',
      'Use Lightning Login for Salesforce logins, which allows authentication with Salesforce Authenticator instead of a password. Users can individually enroll or cancel their enrollment in Lightning Login.'
    );
    descriptionsMap.put('permissionsmakepayments', 'Pay for purchases.');
    descriptionsMap.put(
      'permissionsmanageaccesspolicies',
      'Grants users access to view, create, edit, and delete Enforcement Policies'
    );
    descriptionsMap.put(
      'permissionsmanagepvtrptsanddashbds',
      'Allows full access to reports and dashboards in all other users\' private folders (API only).'
    );
    descriptionsMap.put(
      'permissionsmanageauthproviders',
      'Create and edit Auth. Providers'
    );
    descriptionsMap.put(
      'permissionseditbillinginfo',
      'Purchase additional licenses and features.'
    );
    descriptionsMap.put(
      'permissionsbotmanagebots',
      'Manage bot configuration.'
    );
    descriptionsMap.put(
      'permissionsbotmanagebotstrainingdata',
      'View and manage bot training data.'
    );
    descriptionsMap.put(
      'permissionsmanagecertificates',
      'Ability to manage certificates'
    );
    descriptionsMap.put(
      'permissionsmanagechattermessages',
      'Access all users\' messages sent in Chatter.'
    );
    descriptionsMap.put(
      'permissionsmanageremoteaccess',
      'Manage, create, edit, and delete connected applications.'
    );
    descriptionsMap.put(
      'permissionsinsightsappadmin',
      'Access all CRM Analytics features.'
    );
    descriptionsMap.put(
      'permissionscanmanagemaps',
      'Add, edit, and delete maps, and upload geoJSONs.'
    );
    descriptionsMap.put(
      'permissionswavemanageprivateassetsuser',
      'Delete CRM Analytics datasets in other users\' My Private Apps.'
    );
    descriptionsMap.put(
      'permissionsmanagesubscriptions',
      'Read and delete user subscriptions in Lightning Experience.'
    );
    descriptionsMap.put(
      'permissionsmanagetemplatedapp',
      'Create and manage apps based on available app templates.'
    );
    descriptionsMap.put(
      'permissionsmanagecustomdomains',
      'Create, edit, and delete custom domains and custom URLs.'
    );
    descriptionsMap.put(
      'permissionsmanagecustompermissions',
      'Create, edit, and delete custom permissions.'
    );
    descriptionsMap.put(
      'permissionsmanagecustomreporttypes',
      'Create, edit, and delete custom report types.'
    );
    descriptionsMap.put(
      'permissionsmanagedashbdsinpubfolders',
      'Create, edit, delete dashboards, and manage their sharing in all public folders.'
    );
    descriptionsMap.put(
      'permissionsmanagedatacategories',
      'Create, edit, and delete data categories.'
    );
    descriptionsMap.put(
      'permissionsmanagedataintegrations',
      'Monitor or abort Bulk API jobs.'
    );
    descriptionsMap.put(
      'permissionsmanagedatamaskpolicies',
      'Create, edit, and update Data Mask policies.'
    );
    descriptionsMap.put(
      'permissionsmanagedataspacescope',
      'Grants users access to view, create, edit, and delete a Dataspace Scope'
    );
    descriptionsMap.put(
      'permissionsmanagedynamicdashboards',
      'Create, edit, and delete dynamic dashboards.'
    );
    descriptionsMap.put(
      'permissionsmanageemailclientconfig',
      'Create, edit, and delete Outlook configurations for Salesforce for Outlook.'
    );
    descriptionsMap.put(
      'permissionsmanageencryptionkeys',
      'Manage tenant secrets.'
    );
    descriptionsMap.put(
      'permissionsgovernnetworks',
      'Access Experience Management to view site dashboards and set up Reputation point system and levels.'
    );
    descriptionsMap.put(
      'permissionsmanagehealthassessments',
      'Create and edit Health Assessments data'
    );
    descriptionsMap.put(
      'permissionsmanagehealthcheck',
      'Ability to create new custom health check baselines'
    );
    descriptionsMap.put(
      'permissionsmanageherokuapplink',
      'Manage Heroku AppLink connections and imports'
    );
    descriptionsMap.put(
      'permissionsmanageintegrationconnections',
      'Create, view, edit, delete, and share all connections in the org.'
    );
    descriptionsMap.put(
      'permissionsmanageintegrationportals',
      'Create, edit, delete, and configure Integration Portals.'
    );
    descriptionsMap.put(
      'permissionsuseteamsforitsrvcs',
      'Gives users the ability to use Microsoft Teams to manage and resolve IT issues and service requests, swarm on critical and urgent issues, and collaborate with stakeholders and team members.'
    );
    descriptionsMap.put(
      'permissionslearningmanager',
      'Gives user permission to create Learning items.'
    );
    descriptionsMap.put(
      'permissionsmanagelearningreporting',
      'Create reports with associated objects for Learning Paths.'
    );
    descriptionsMap.put(
      'permissionseditbrandtemplates',
      'Create, edit, and delete letterheads for HTML emails.'
    );
    descriptionsMap.put(
      'permissionsmanageexchangeconfig',
      'Gives access to Lightning Sync Setup, Configurations, and Status pages in Salesforce Setup.'
    );
    descriptionsMap.put(
      'permissionsmanagetwofactor',
      'Use the API to manage user identity verification methods for multi-factor authentication.'
    );
    descriptionsMap.put(
      'permissionsdelegatedtwofactor',
      'Use tools in the user interface to manage and provide user support for multi-factor authentication.'
    );
    descriptionsMap.put(
      'permissionsmanagemobile',
      'Access Salesforce Classic features.'
    );
    descriptionsMap.put(
      'permissionsmanagepropositions',
      'Create, update, and delete recommendations. Recommendations represent offers and actions that are recommended to users and customers as part of Next Best Action functionality. They are used with action strategies.'
    );
    descriptionsMap.put(
      'permissionsmanagerecommendationstrategies',
      'Create, update, and delete action strategies. Action strategies determine which recommendations are presented to users as Next Best Actions.'
    );
    descriptionsMap.put(
      'permissionsmanageocirecords',
      'Manage Omnichannel Inventory Records'
    );
    descriptionsMap.put(
      'permissionsmanagecustomerdataoptout',
      'Grants users access to manage opt-out settings for customer data access'
    );
    descriptionsMap.put(
      'permissionsmanagepackagelicenses',
      'Manage package licenses in subscriber organizations.'
    );
    descriptionsMap.put(
      'permissionsmanagefilesandattachments',
      'Allows a user to define copy files and attachments in policies.'
    );
    descriptionsMap.put(
      'permissionsmanagesearchpromotionrules',
      'Create, edit, and delete promoted search terms.'
    );
    descriptionsMap.put(
      'permissionseditpublictemplates',
      'Create, edit, and delete text emails, mail merge templates, and folders for public email templates.'
    );
    descriptionsMap.put(
      'permissionseditpublicdocuments',
      'Create, edit, and delete folders for public documents.'
    );
    descriptionsMap.put(
      'permissionscreateltngtempinpub',
      'Manage Lightning email templates in the public folder.'
    );
    descriptionsMap.put(
      'permissionseditpublicfilters',
      'Create, edit, and delete public list views.'
    );
    descriptionsMap.put(
      'permissionsmanagereleaseupdates',
      'Apply release updates and enable or disable test runs.'
    );
    descriptionsMap.put(
      'permissionsmanageanalyticsnapshots',
      'Create, edit, and delete reporting snapshots.'
    );
    descriptionsMap.put(
      'permissionsmanagereportsinpubfolders',
      'Create, edit, delete reports, and manage their sharing in all public folders.'
    );
    descriptionsMap.put(
      'permissionsmanagesecuritycommandcenter',
      'View all Security Center pages and manage app configurations. Requires Security Center license.'
    );
    descriptionsMap.put(
      'permissionsmanagesessionpermissionsets',
      'Add or remove activation records for session-based permission sets.'
    );
    descriptionsMap.put(
      'permissionsmanagesharedlistviews',
      'Create, edit, and delete shared list views.'
    );
    descriptionsMap.put('permissionsmanagestores', 'Manage store settings.');
    descriptionsMap.put(
      'permissionsmanagesurveys',
      'Create, Edit and Delete Surveys.'
    );
    descriptionsMap.put(
      'permissionsmanagesynonyms',
      'Create, edit, and delete synonym groups.'
    );
    descriptionsMap.put(
      'permissionsmanageunlistedgroups',
      'View and moderate unlisted Chatter groups.'
    );
    descriptionsMap.put(
      'permissionsuseservicepartreturn',
      'Allow users to access Manufacturing Cloud Service Part Return Management features.'
    );
    descriptionsMap.put(
      'permissionsmassinlineedit',
      'Edit multiple records simultaneously from a list with inline editing.'
    );
    descriptionsMap.put(
      'permissionsemailmass',
      'Send mass emails to contacts and leads.'
    );
    descriptionsMap.put('permissionsmergetopics', 'Merge one or more topics.');
    descriptionsMap.put(
      'permissionsmetadatastudiouser',
      'View Metadata studio Tab'
    );
    descriptionsMap.put(
      'permissionscmseceauthoringaccess',
      'Upload migrated content from your enablement site to the Enablement workspace in Digital Experiences.'
    );
    descriptionsMap.put(
      'permissionsqrcodegeneratormobilepublisherplayground',
      'Allows a user the options to generate a QR Code encoded with a One Time Login URL for Mobile Publisher Playground Apps'
    );
    descriptionsMap.put(
      'permissionsmoderatechatter',
      'Deactivate Chatter Free users, assign moderator privileges to Chatter Free users, and remove posts.'
    );
    descriptionsMap.put(
      'permissionsmoderatenetworkusers',
      'Allows users to manage Experience Cloud site member access, such as freezing a user.'
    );
    descriptionsMap.put(
      'permissionsmodifyalldata',
      'Create, edit, and delete all organization data, regardless of sharing settings.'
    );
    descriptionsMap.put(
      'permissionsmodifyaccessallowpolicies',
      'Create, edit, and delete Allow policies in the Data Governance tab'
    );
    descriptionsMap.put(
      'permissionsmodifyallpolicycenterpolicies',
      'Create, edit, and delete all Policies in the Policy Center App. Specific policy types may require additional permissions.'
    );
    descriptionsMap.put(
      'permissionsmodifydataclassification',
      'View and modify field-level data classification metadata.'
    );
    descriptionsMap.put(
      'permissionsmodifyaccessdenypolicies',
      'Create, edit, and delete Deny policies in the Data Governance tab'
    );
    descriptionsMap.put(
      'permissionsmodifymetadata',
      'Create, read, edit, and delete org metadata. Users must have appropriate access rights to the metadata they\'re trying to modify. Be careful if delegating this permission. Some metadata executes in system context, when object permissions, field-level security, and sharing rules that apply to the user are ignored. For example, Apex executes in system context.'
    );
    descriptionsMap.put(
      'permissionsmodifytransactionsecuritypolicies',
      'Allow create, update, and delete of Transaction Security Policies.'
    );
    descriptionsMap.put(
      'permissionstwofactorapi',
      'Require users to enter a code from a time-based one-time password (TOTP) authenticator app instead of the emailed security token in the API.'
    );
    descriptionsMap.put(
      'permissionsforcetwofactor',
      'Require users to provide an additional verification method in addition to their username and password when logging in to Salesforce orgs.'
    );
    descriptionsMap.put(
      'permissionsusequerysuggestions',
      'Show results for natural language searches and list views.'
    );
    descriptionsMap.put(
      'permissionsomnichannelinventorybasic',
      'Allow access to the basic inventory functionality using the Omnichannel Inventory Service APIs.'
    );
    descriptionsMap.put(
      'permissionsomnichannelinventorysync',
      'Sync inventory using the Omnichannel Inventory Service APIs.'
    );
    descriptionsMap.put(
      'permissionspasswordneverexpires',
      'Prevent the user\'s password from expiring.'
    );
    descriptionsMap.put(
      'permissionspaymentsapiuser',
      'Allow users to access CCS Payments apis'
    );
    descriptionsMap.put(
      'permissionspersonalizationinteluser',
      'Allows user to install and access Personalization Intelligence Dashboard'
    );
    descriptionsMap.put(
      'permissionsfeedpinning',
      'Assign permission to pin a Chatter post in this org and your Experience Cloud sites.'
    );
    descriptionsMap.put(
      'permissionsprismbackofficeuser',
      'View Prism Backoffice Page'
    );
    descriptionsMap.put(
      'permissionsprismplaygrounduser',
      'View Prism Playground Tab'
    );
    descriptionsMap.put(
      'permissionspackaging2promoteversion',
      'Promote a package version to released.'
    );
    descriptionsMap.put(
      'permissionsproposemajorincidents',
      'Allows users to propose incidents as major incidents.'
    );
    descriptionsMap.put(
      'permissionsaccesstocomplaintagent',
      'Grants users the access to Complaint Fulfilment Agent'
    );
    descriptionsMap.put(
      'permissionsaccessdisputeprompts',
      'Provides access to Financial Services Email prompt templates.'
    );
    descriptionsMap.put(
      'permissionsregrellouser',
      'Provides user permission to access the Regrello App.'
    );
    descriptionsMap.put(
      'permissionspersonalizationdecisioninguser',
      'Provides users access to the Personalization Decisions invocable action.'
    );
    descriptionsMap.put(
      'permissionsaccesstocomplaintmgmt',
      'Grants users the access to Complaint Management Data'
    );
    descriptionsMap.put(
      'permissionsschedulinglineambassador',
      'Allows users to view a queue and create queued parties.'
    );
    descriptionsMap.put(
      'permissionsquipmetricsaccess',
      'Allows users to access Quip metrics.'
    );
    descriptionsMap.put(
      'permissionsquipuserengagementmetrics',
      'Allow users to access Quip user engagement metrics.'
    );
    descriptionsMap.put(
      'permissionsmanagecertificatesexpiration',
      'Receive email notifications 60, 30, and 10 days before a certificate expires.'
    );
    descriptionsMap.put(
      'permissionscanviewdatapreprecipe',
      'Provides access in data manager to view the recipe list and open recipes in view-only mode'
    );
    descriptionsMap.put('permissionsrefundpayments', 'Refund payments.');
    descriptionsMap.put(
      'permissionsltngpromoreserved01userperm',
      'Gives the user ability to remain in Salesforce Classic instead of being switched to Lightning Experience automatically.'
    );
    descriptionsMap.put(
      'permissionsremovedirectmessagemembers',
      'Lets a user remove others from direct messages the user is in.'
    );
    descriptionsMap.put(
      'permissionsreopenproblems',
      'Allows users to reopen problems.'
    );
    descriptionsMap.put(
      'permissionsnewreportbuilder',
      'Create, edit, and delete reports using the classic report builder interface.'
    );
    descriptionsMap.put(
      'permissionscreatereportinlightning',
      'Create, edit, and delete reports using the enhanced report builder interface. Only available in Lightning Experience.'
    );
    descriptionsMap.put(
      'permissionsresolvechgrqstassoc',
      'Allows users to resolve all associated records for a change request.'
    );
    descriptionsMap.put(
      'permissionsresolveincassoc',
      'Allows users to resolve all associated records for an incident.'
    );
    descriptionsMap.put(
      'permissionsresolveprobassoc',
      'Allows users to resolve all associated records for a problem.'
    );
    descriptionsMap.put(
      'permissionsrunmydayuser',
      'Grants user access to Run My Day features.'
    );
    descriptionsMap.put('permissionsrunreports', 'Run reports and dashboards.');
    descriptionsMap.put(
      'permissionsisotopelex',
      'Use Salesforce Anywhere in Lightning Experience'
    );
    descriptionsMap.put(
      'permissionsisotopectocuser',
      'Salesforce Anywhere integration user access'
    );
    descriptionsMap.put(
      'permissionsisotopeaccess',
      'Use the Salesforce Anywhere mobile app'
    );
    descriptionsMap.put(
      'permissionsnativewebviewscrolling',
      'Replace ui:scroller with native scrolling on webviews. Users experience smoother scrolling.'
    );
    descriptionsMap.put(
      'permissionsenhancedsalesmobileexp',
      'Sellers can use the Sales Cloud Mobile Lightning app within the Salesforce mobile app.'
    );
    descriptionsMap.put(
      'permissionssalesinsightsuser',
      'Identifies users with access to Revenue Insights App.'
    );
    descriptionsMap.put(
      'permissionsschedulereports',
      'Schedule report refreshes in Salesforce Classic, and send email notifications that include refreshed reports in HTML format. Your organization\'s data may be saved and/or processed by third-party services, and Salesforce is not responsible for data users choose to send outside of Salesforce.'
    );
    descriptionsMap.put(
      'permissionssegmentintelligenceuser',
      'View Segment Intelligence Tab and Dashboard'
    );
    descriptionsMap.put(
      'permissionsselectfilesfromsalesforce',
      'Selecting a Salesforce file is an option when attaching a file.'
    );
    descriptionsMap.put(
      'permissionssendannouncementemails',
      'Allows email notifications to be sent when a user posts an announcement in Chatter.'
    );
    descriptionsMap.put(
      'permissionssendcustomnotifications',
      'Trigger the Send Custom Notification action in flows that run in user context, REST API calls, and Apex callouts.'
    );
    descriptionsMap.put(
      'permissionsemailsingle',
      'Send email to a single contact or lead.'
    );
    descriptionsMap.put(
      'permissionstransactionalemailsend',
      'Send non-commercial end-user emails to contacts, leads, and person accounts who opt out of email or who choose Don\'t Market in data privacy records. This permission doesn\'t apply to the Cases email action, Lightning Experience list email, or Salesforce Classic mass email.'
    );
    descriptionsMap.put(
      'permissionsenablenotifications',
      'Send outbound messages to an external Web service API.'
    );
    descriptionsMap.put(
      'permissionsaccesstoserviceprocess',
      'Grants users the access to Service Process Data'
    );
    descriptionsMap.put(
      'permissionsenablecommunityapplauncher',
      'Display the App Launcher icon in Experience Cloud sites.'
    );
    descriptionsMap.put(
      'permissionsshowcompanynameasuserbadge',
      'Allow users to see other users\' company name in site role.'
    );
    descriptionsMap.put(
      'permissionscustomsidebaronallpages',
      'Display a custom sidebar on all pages in Salesforce.com.'
    );
    descriptionsMap.put(
      'permissionsskipidentityconfirmation',
      'Allow a Salesforce Customer Support representative to log in to this org without verifying their identity in order to troubleshoot an issue.'
    );
    descriptionsMap.put(
      'permissionsslackbotui',
      'Allows a user to access Slackbot UI in LEX.'
    );
    descriptionsMap.put(
      'permissionsstagemanagementdesignuser',
      'Provides user access to Stage Management Designer.'
    );
    descriptionsMap.put(
      'permissionsusesubscriptionemails',
      'Subscribe to CRM Analytics lenses and dashboard widgets to send scheduled status updates by email, or subscribe to CRM Analytics dashboards in Slack. For subscribing to tables, the Download Analytics Data permission is also required. Your organization\'s data may be saved and/or processed by third-party services, and Salesforce is not responsible for data users choose to send outside of Salesforce.'
    );
    descriptionsMap.put(
      'permissionssubscribetolightningdashboards',
      'Subscribe to dashboards in Lightning Experience to schedule dashboard refreshes and send notifications by email. Your organization\'s data may be saved and/or processed by third-party services, and Salesforce is not responsible for data users choose to send outside of Salesforce.'
    );
    descriptionsMap.put(
      'permissionssubscribedashboardtootherusers',
      'Specify recipients of email notifications from dashboard subscriptions in Lightning Experience. All recipient email addresses appear in the subscription email\'s "to:" field, so subscription email recipients will be able to see each other\'s email addresses regardless of User Sharing settings.'
    );
    descriptionsMap.put(
      'permissionssubscribedashboardrolesgrps',
      'Set public groups and roles as recipients of dashboard subscriptions in Lightning Experience.'
    );
    descriptionsMap.put(
      'permissionssubscribetolightningreports',
      'Subscribe to reports in Lightning Experience to schedule report refreshes and send notifications by email. Your organization\'s data may be saved and/or processed by third-party services, and Salesforce is not responsible for data users choose to send outside of Salesforce.'
    );
    descriptionsMap.put(
      'permissionssubscribereporttootherusers',
      'Specify recipients of email notifications from report subscriptions in Lightning Experience. All recipient email addresses appear in the subscription email\'s "to:" field, so subscription email recipients will be able to see other\'s email addresses regardless of User Sharing settings.'
    );
    descriptionsMap.put(
      'permissionssubscribereportrolesgrps',
      'Set public groups and roles as recipients of report subscriptions in Lightning Experience.'
    );
    descriptionsMap.put(
      'permissionssubscribereportsrunasuser',
      'Specify who report subscription recipients see report data as. The specified person\'s data access determines what data the report displays.'
    );
    descriptionsMap.put(
      'permissionssandboxtestingincommunityapp',
      'Allows testing a sandbox experience in the mobile publisher for Experience Cloud.'
    );
    descriptionsMap.put(
      'permissionstransferanyentity',
      'Change the owner of most records.'
    );
    descriptionsMap.put(
      'permissionscanqueryforeigntables',
      'Grant users permission to query data outside of Salesforce without creating a related DLO'
    );
    descriptionsMap.put(
      'permissionsconsentapiupdate',
      'Use the PATCH method on the Consent REST API resource to update consent preferences.'
    );
    descriptionsMap.put(
      'permissionscanupdateemailmessage',
      'Modify certain email message related records.'
    );
    descriptionsMap.put(
      'permissionspublishpackaging',
      'Upload packages to AppExchange for distribution.'
    );
    descriptionsMap.put(
      'permissionsinsightsappuploaduser',
      'Upload external data files through the CRM Analytics user interface to create datasets.'
    );
    descriptionsMap.put(
      'permissionsuploadsolutionbundlestorepository',
      'Allows users to upload solution bundles to an associated repository.'
    );
    descriptionsMap.put(
      'permissionsuseadvanceddeliveryestimationapi',
      'Allow user to access the Advanced Delivery Estimation Service APIs'
    );
    descriptionsMap.put(
      'permissionsuseanyapiauth',
      'Allows authentication via SOAP API login() when SOAP login access is restricted by the org.'
    );
    descriptionsMap.put(
      'permissionsinsightsappuser',
      'Run apps to which you have access; view their datasets, lenses, and dashboards; and create and edit lenses.'
    );
    descriptionsMap.put(
      'permissionsusetemplatedapp',
      'View apps based on available app templates.'
    );
    descriptionsMap.put(
      'permissionsusedeliveryestimationapis',
      'Allow user to access the Delivery Estimation Service APIs.'
    );
    descriptionsMap.put(
      'permissionsintelligentdocumentprocessing',
      'Extract data from documents using generative AI.'
    );
    descriptionsMap.put(
      'permissionsidentityconnect',
      'Gives the user access to the Identity Connect product which provides Active Directory integration.'
    );
    descriptionsMap.put(
      'permissionsidentityenabled',
      'Gives the user access to Identity features such as App Launcher.'
    );
    descriptionsMap.put(
      'permissionsuseomnichannelinventoryapis',
      'Manage inventory using the Omnichannel Inventory Service APIs.'
    );
    descriptionsMap.put(
      'permissionsallowociavailabilityapis',
      'Use Omnichannel Inventory Availability APIs'
    );
    descriptionsMap.put(
      'permissionsuseorderentry',
      'Allows a user to create orders in Salesforce Order Management.'
    );
    descriptionsMap.put(
      'permissionsuseaddorderitemsummaryapis',
      'Call the Order Management Add Order Item Summary APIs. Required for product exchanges.'
    );
    descriptionsMap.put(
      'permissionsuseomanalytics',
      'Access Order Management analytic features and API.'
    );
    descriptionsMap.put(
      'permissionsuseexchangesapis',
      'Allows a user to call the Order Management Exchange APIs.'
    );
    descriptionsMap.put(
      'permissionsusefulfillmentapis',
      'Allows a user to call the Order Management Fulfillment APIs.'
    );
    descriptionsMap.put(
      'permissionsusefulfillmentroutingapis',
      'Allows a user to call the Order Management Fulfillment Routing APIs.'
    );
    descriptionsMap.put(
      'permissionsuseordersummarychangeapis',
      'Allows a user to call the Order Management Order Summary Change APIs.'
    );
    descriptionsMap.put(
      'permissionsusepaymentcreditapis',
      'Allows a user to call the Order Management Payment Credit APIs.'
    );
    descriptionsMap.put(
      'permissionsusereturnorderapis',
      'Allows a user to call the Order Management Return Order APIs.'
    );
    descriptionsMap.put(
      'permissionsusereturnorder',
      'Allows a user to access the Order Management Return Order Objects.'
    );
    descriptionsMap.put(
      'permissionsviewpayments',
      'Use the Payments app to access payments functions.'
    );
    descriptionsMap.put(
      'permissionsuseregisterguestbuyerapi',
      'Allows a user to call the Register Guest Buyer API.'
    );
    descriptionsMap.put(
      'permissionsuserepricing',
      'Allow access to order product repricing features.'
    );
    descriptionsMap.put(
      'permissionsuserestrictedtheme',
      'View Salesforce with the active restricted theme instead of the default theme.'
    );
    descriptionsMap.put(
      'permissionshasunlimitednbaexecutions',
      'Execute unlimited number of action strategies.'
    );
    descriptionsMap.put(
      'permissionsfsccomprehensiveuseraccess',
      'User license to access Lightning components and features delivered in Financial Services Cloud.'
    );
    descriptionsMap.put(
      'permissionsusercandeploystore',
      'Users can perform the deployment operation on a store.'
    );
    descriptionsMap.put(
      'permissionsusesetupwithagentforce',
      'Use the AI agent in Setup to get information, troubleshoot issues, and complete administrative tasks.'
    );
    descriptionsMap.put(
      'permissionsuseomsdrointeropapis',
      'Use the Order Management and Dynamic Revenue Orchestrator Integration APIs.'
    );
    descriptionsMap.put(
      'permissionscanverifycomment',
      'Mark answers to Chatter questions as verified.'
    );
    descriptionsMap.put(
      'permissionsviewaccesspolicies',
      'Grants users access to view Enforcement Policies'
    );
    descriptionsMap.put(
      'permissionsviewagtfrceanlytdshbrd',
      'Allows users access to the Tableau Next Analytics Agentforce dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewitsmconsoleasfulfr',
      'Allows IT fulfillers access to the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewitsmconsolehmpg',
      'Allows users access to the home page of the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsaiviewinsightobjects',
      'View objects associated with AI record insights, including the insight, value, reason, and feedback.'
    );
    descriptionsMap.put(
      'permissionsviewallcustomsettings',
      'Let users view all custom setting data directly and via the API.'
    );
    descriptionsMap.put(
      'permissionsviewalldata',
      'View all organizational data, regardless of sharing settings.'
    );
    descriptionsMap.put(
      'permissionsexternalclientappviewer',
      'View all External Client Apps.'
    );
    descriptionsMap.put(
      'permissionsexternalclientappadmin',
      'View all External Client Apps, view their settings, and edit their policies.'
    );
    descriptionsMap.put(
      'permissionsviewallfieldsglobal',
      'View all fields and field data, regardless of assigned field permissions. To see an object\'s fields, the user must also have the required object permissions.'
    );
    descriptionsMap.put(
      'permissionsviewallforeignkeynames',
      'View the record names in lookup fields regardless of sharing settings. Lookup fields include system fields, such as Created By and Last Modified By.'
    );
    descriptionsMap.put(
      'permissionsviewallpolicycenterpolicies',
      'View all Policies in the Policy Center App. Specific policy types may require additional permissions.'
    );
    descriptionsMap.put(
      'permissionsviewcaseanlytdshbrd',
      'Allows users access to the Tableau Next Analytics Case dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewchangerequestanlytdshbrd',
      'Allows users access to the Tableau Next Analytics Change Request dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewchangerequestdshbrd',
      'Allows users access to the standard Change Request dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewuserpii',
      'View field data, such as sensitive or personally identifiable information, that is concealed from other users.'
    );
    descriptionsMap.put(
      'permissionswavecommunityuser',
      'Can view shared CRM Analytics assets from within experiences.'
    );
    descriptionsMap.put(
      'permissionsviewpublicdashboards',
      'View and access dashboards in public folders, which does not include others\' personal folders.'
    );
    descriptionsMap.put(
      'permissionsviewdatacategories',
      'View the Data Categories page.'
    );
    descriptionsMap.put(
      'permissionsviewdevelopername',
      'View the DeveloperName field via the API.'
    );
    descriptionsMap.put(
      'permissionsviewencrypteddata',
      'View the value of encrypted fields in plain text.'
    );
    descriptionsMap.put(
      'permissionsvieweventlogfiles',
      'Get CSV event log files via the API.'
    );
    descriptionsMap.put(
      'permissionsviewclientsecret',
      'Allows users to view External Client App consumer secrets in Metadata API responses. Exercise caution when allowing users to access consumer secrets.'
    );
    descriptionsMap.put(
      'permissionsviewhealthassessments',
      'Read Health Assessments data'
    );
    descriptionsMap.put(
      'permissionsviewhealthcheck',
      'View Security Health Check Page'
    );
    descriptionsMap.put(
      'permissionsviewhelplink',
      'Allow user to view help link.'
    );
    descriptionsMap.put(
      'permissionsviewincidentanlytdshbrd',
      'Allows users access to the Tableau Next Analytics Incident dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewincidentfulfrdshbrd',
      'Allows users access to the standard Incident Fulfiller dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewincidentmgrdshbrd',
      'Allows users access to the standard Incident Manager dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewitleaderanlytdshbrd',
      'Allows users access to the Tableau Next Analytics IT Leader dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewknwlganlytdshbrd',
      'Allows users access to the Tableau Next Analytics Knowledge dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewplatformevents',
      'Query Login Forensics events using the API.'
    );
    descriptionsMap.put(
      'permissionsviewmyteamsdashboards',
      'View dashboards owned by people under them in the role hierarchy.'
    );
    descriptionsMap.put(
      'permissionsviewomnichnlanlytdshbrd',
      'Allows users access to the Tableau Next Analytics Omnichannel dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewprivatestaticresources',
      'View Static Resources with Cache Control set to Private. Enabled by default for all profiles except for guest user profiles.'
    );
    descriptionsMap.put(
      'permissionsviewproblemfulfrdshbrd',
      'Allows users access to the standard Problem Fulfiller dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewproblemmgrdshbrd',
      'Allows users access to the standard Problem Manager dashboard available in the Agentic IT Service Desk app.'
    );
    descriptionsMap.put(
      'permissionsviewpubliccapstonefolders',
      'View Public Capstone Folder'
    );
    descriptionsMap.put(
      'permissionsviewdataleakageevents',
      'Query Real-Time Event Monitoring Data using the API.'
    );
    descriptionsMap.put(
      'permissionsviewrecommendations',
      'View Einstein Next Best Action Recommendation records for an Experience Cloud site user.'
    );
    descriptionsMap.put(
      'permissionsviewpublicreports',
      'View and access reports in public folders, which does not include others\' personal folders.'
    );
    descriptionsMap.put(
      'permissionsviewrestrictionandscopingrules',
      'View Restriction and Scoping Rules.'
    );
    descriptionsMap.put(
      'permissionsviewroles',
      'Allow user to view roles and role hierarchy.'
    );
    descriptionsMap.put(
      'permissionsviewsecuritycommandcenter',
      'View licensed Security Center or unlicensed Security Center Essentials pages.'
    );
    descriptionsMap.put(
      'permissionsviewsetup',
      'View the App Setup and Administrative Settings pages.'
    );
    descriptionsMap.put(
      'permissionsviewshieldapp',
      'View the Shield App pages for Data Detect, Field Audit Trail, Platform Encryption and Event Monitoring.'
    );
    descriptionsMap.put(
      'permissionsviewanomalyevents',
      'Allows user to view the threat detection events.'
    );
    descriptionsMap.put(
      'permissionsdataexport',
      'Run the weekly data export service.'
    );
    descriptionsMap.put(
      'permissionsassignpermissionsets',
      'Assign permission sets to users.'
    );
    descriptionsMap.put('permissionsfreezeusers', 'Freeze and unfreeze users.');
    descriptionsMap.put(
      'permissionsmanageinternalusers',
      'Create and edit internal users.'
    );
    descriptionsMap.put(
      'permissionsmanageipaddresses',
      'Create, edit, and delete trusted IP ranges.'
    );
    descriptionsMap.put(
      'permissionsmanageloginaccesspolicies',
      'Specify the login access policies that apply to administrators and support organizations.'
    );
    descriptionsMap.put(
      'permissionsmanagepasswordpolicies',
      'Set password restrictions and login lockout policies for all users.'
    );
    descriptionsMap.put(
      'permissionsmanageprofilespermissionsets',
      'Create, edit, and delete profiles and permission sets.'
    );
    descriptionsMap.put(
      'permissionsmanageroles',
      'Create, edit, and delete roles.'
    );
    descriptionsMap.put(
      'permissionsmanagesharing',
      'Create, edit, and recalculate sharing rules, edit organization-wide defaults, and enable the external sharing model.'
    );
    descriptionsMap.put(
      'permissionsmanageusers',
      'Create, edit, and deactivate users, and manage security settings, including profiles and roles.'
    );
    descriptionsMap.put(
      'permissionsmonitorloginhistory',
      'View and download login history, and create login history custom list views.'
    );
    descriptionsMap.put(
      'permissionsresetpasswords',
      'Unlock users whose accounts are locked, and reset user passwords.'
    );
    descriptionsMap.put(
      'permissionsviewallprofiles',
      'View all user profiles, regardless of profile filtering setting.'
    );
    descriptionsMap.put(
      'permissionsviewallusers',
      'View all users, regardless of sharing settings.'
    );
    return descriptionsMap;
  }

  @AuraEnabled(cacheable=true)
  public static List<SystemPermissionWrapper> getSystemPermissions(
    List<Id> profileIds,
    List<Id> permissionSetIds
  ) {
    try {
      List<SystemPermissionWrapper> enabledPermissions = new List<SystemPermissionWrapper>();
      Set<Id> unifiedPermissionSetIds = PermissionService.getUnifiedPermissionSetIds(
        profileIds,
        permissionSetIds
      );

      if (unifiedPermissionSetIds.isEmpty()) {
        return enabledPermissions;
      }

      Map<String, Schema.SObjectField> psFields = Schema.sObjectType.PermissionSet.fields.getMap();
      Map<String, AppPermissionsController.AppPermissionInfo> appPerms = AppPermissionsController.getAppPermissionsMap();
      Map<String, String> descs = getDescriptionsMap();

      List<String> validQueryFields = new List<String>();
      Map<String, String> fieldLabels = new Map<String, String>();
      Map<String, String> shortApiNames = new Map<String, String>();

      for (String fieldLower : psFields.keySet()) {
        if (
          fieldLower.startsWith('permissions') &&
          !appPerms.containsKey(fieldLower)
        ) {
          Schema.DescribeFieldResult dfr = psFields.get(fieldLower)
            .getDescribe();
          if (dfr.getType() == Schema.DisplayType.Boolean) {
            String fieldName = dfr.getName();
            validQueryFields.add(fieldName);
            fieldLabels.put(fieldLower, dfr.getLabel());
            shortApiNames.put(
              fieldLower,
              fieldName.replaceFirst('^Permissions', '')
            );
          }
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

      for (String fieldName : validQueryFields) {
        String fieldLower = fieldName.toLowerCase();
        if (enabledFieldNames.contains(fieldLower)) {
          String shortName = shortApiNames.get(fieldLower);
          String label = fieldLabels.get(fieldLower);
          String permDescription = descs.containsKey(fieldLower)
            ? descs.get(fieldLower)
            : '';
          enabledPermissions.add(
            new SystemPermissionWrapper(shortName, label, permDescription)
          );
        }
      }

      return enabledPermissions;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class SystemPermissionWrapper {
    @AuraEnabled
    public String apiName { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String description { get; set; }

    public SystemPermissionWrapper(
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
