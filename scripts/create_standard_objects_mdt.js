const fs = require("fs");
const path = require("path");

const standardObjects = [
  // Sales Cloud & Core CRM
  { apiName: "Account", label: "Account" },
  { apiName: "Contact", label: "Contact" },
  { apiName: "Lead", label: "Lead" },
  { apiName: "Opportunity", label: "Opportunity" },
  { apiName: "OpportunityLineItem", label: "Opportunity Product" },
  { apiName: "OpportunityContactRole", label: "Opportunity Contact Role" },
  { apiName: "OpportunityPartner", label: "Opportunity Partner" },
  { apiName: "OpportunityCompetitor", label: "Opportunity Competitor" },
  { apiName: "Campaign", label: "Campaign" },
  { apiName: "CampaignMember", label: "Campaign Member" },
  { apiName: "Product2", label: "Product" },
  { apiName: "Pricebook2", label: "Price Book" },
  { apiName: "PricebookEntry", label: "Price Book Entry" },
  { apiName: "Contract", label: "Contract" },
  { apiName: "ContractContactRole", label: "Contract Contact Role" },
  { apiName: "Order", label: "Order" },
  { apiName: "OrderItem", label: "Order Product" },
  { apiName: "Quote", label: "Quote" },
  { apiName: "QuoteLineItem", label: "Quote Line Item" },
  { apiName: "Partner", label: "Partner" },
  { apiName: "AccountPartner", label: "Account Partner" },
  { apiName: "AccountContactRole", label: "Account Contact Role" },
  { apiName: "Asset", label: "Asset" },
  { apiName: "AssetRelationship", label: "Asset Relationship" },
  { apiName: "DandBCompany", label: "D&amp;B Company" },
  { apiName: "Scorecard", label: "Scorecard" },
  { apiName: "ScorecardMetric", label: "Scorecard Metric" },
  { apiName: "ScorecardAssociation", label: "Scorecard Association" },

  // Service Cloud & Contact Center
  { apiName: "Case", label: "Case" },
  { apiName: "CaseComment", label: "Case Comment" },
  { apiName: "CaseContactRole", label: "Case Contact Role" },
  { apiName: "CaseSolution", label: "Case Solution" },
  { apiName: "Solution", label: "Solution" },
  { apiName: "Entitlement", label: "Entitlement" },
  { apiName: "ServiceContract", label: "Service Contract" },
  { apiName: "ContractLineItem", label: "Contract Line Item" },
  { apiName: "WorkOrder", label: "Work Order" },
  { apiName: "WorkOrderLineItem", label: "Work Order Line Item" },
  { apiName: "QuickText", label: "Quick Text" },
  { apiName: "Macro", label: "Macro" },
  { apiName: "ReturnOrder", label: "Return Order" },
  { apiName: "ReturnOrderLineItem", label: "Return Order Line Item" },
  { apiName: "MessagingEndUser", label: "Messaging User" },
  { apiName: "MessagingSession", label: "Messaging Session" },

  // Field Service & Lightning Scheduler
  { apiName: "ServiceAppointment", label: "Service Appointment" },
  { apiName: "ServiceResource", label: "Service Resource" },
  { apiName: "ServiceResourceSkill", label: "Service Resource Skill" },
  { apiName: "ServiceTerritory", label: "Service Territory" },
  { apiName: "ServiceTerritoryMember", label: "Service Territory Member" },
  { apiName: "OperatingHours", label: "Operating Hours" },
  { apiName: "TimeSlot", label: "Time Slot" },
  { apiName: "ResourceAbsence", label: "Resource Absence" },
  { apiName: "ResourcePreference", label: "Resource Preference" },
  { apiName: "AssignedResource", label: "Assigned Resource" },
  { apiName: "WorkType", label: "Work Type" },
  { apiName: "WorkTypeGroup", label: "Work Type Group" },
  { apiName: "WorkTypeGroupMember", label: "Work Type Group Member" },
  { apiName: "Shift", label: "Shift" },
  { apiName: "AppointmentCategory", label: "Appointment Category" },
  { apiName: "AppointmentInvitation", label: "Appointment Invitation" },
  {
    apiName: "AppointmentScheduleAggr",
    label: "Appointment Schedule Aggregate"
  },
  { apiName: "AppointmentScheduleLog", label: "Appointment Schedule Log" },
  { apiName: "AppointmentTopicTimeSlot", label: "Appointment Topic Time Slot" },
  { apiName: "Waitlist", label: "Waitlist" },
  { apiName: "WaitlistParticipant", label: "Waitlist Participant" },

  // Commerce Cloud (B2B & D2C)
  { apiName: "WebStore", label: "Store" },
  { apiName: "WebCart", label: "Cart" },
  { apiName: "CartItem", label: "Cart Item" },
  { apiName: "CartDeliveryGroup", label: "Cart Delivery Group" },
  { apiName: "CartTax", label: "Cart Tax" },
  { apiName: "BuyerGroup", label: "Buyer Group" },
  { apiName: "WebStoreBuyerGroup", label: "WebStore Buyer Group" },
  { apiName: "ProductCatalog", label: "Product Catalog" },
  { apiName: "ProductCategory", label: "Product Category" },
  { apiName: "ProductCategoryProduct", label: "Product Category Product" },
  { apiName: "Promotion", label: "Promotion" },
  { apiName: "PromotionTarget", label: "Promotion Target" },
  { apiName: "PromotionTier", label: "Promotion Tier" },
  { apiName: "PromotionSegment", label: "Promotion Segment" },
  { apiName: "PromotionQualifier", label: "Promotion Qualifier" },
  { apiName: "PromotionMarketSegment", label: "Promotion Market Segment" },
  { apiName: "Coupon", label: "Coupon" },
  { apiName: "CouponCodeRedemption", label: "Coupon Code Redemption" },
  { apiName: "FulfillmentOrder", label: "Fulfillment Order" },
  { apiName: "FulfillmentOrderLineItem", label: "Fulfillment Order Line Item" },
  { apiName: "Shipment", label: "Shipment" },
  { apiName: "ShipmentItem", label: "Shipment Item" },
  { apiName: "ShippingCarrier", label: "Shipping Carrier" },
  { apiName: "ShippingCarrierMethod", label: "Shipping Carrier Method" },
  { apiName: "ShippingConfigurationSet", label: "Shipping Configuration Set" },
  { apiName: "InventoryReservation", label: "Inventory Reservation" },

  // Billing, Revenue & Payments
  { apiName: "Invoice", label: "Invoice" },
  { apiName: "InvoiceLine", label: "Invoice Line" },
  { apiName: "CreditMemo", label: "Credit Memo" },
  { apiName: "CreditMemoLine", label: "Credit Memo Line" },
  {
    apiName: "CreditMemoInvApplication",
    label: "Credit Memo Invoice Application"
  },
  { apiName: "Payment", label: "Payment" },
  { apiName: "PaymentAuthorization", label: "Payment Authorization" },
  { apiName: "PaymentAuthAdjustment", label: "Payment Auth Adjustment" },
  { apiName: "PaymentGateway", label: "Payment Gateway" },
  { apiName: "PaymentGatewayLog", label: "Payment Gateway Log" },
  { apiName: "PaymentGroup", label: "Payment Group" },
  { apiName: "PaymentLineInvoice", label: "Payment Line Invoice" },
  { apiName: "Refund", label: "Refund" },
  { apiName: "RefundLinePayment", label: "Refund Line Payment" },
  { apiName: "DigitalWallet", label: "Digital Wallet" },
  { apiName: "CardPaymentMethod", label: "Card Payment Method" },
  { apiName: "AlternativePaymentMethod", label: "Alternative Payment Method" },
  { apiName: "LegalEntity", label: "Legal Entity" },
  { apiName: "FinanceBalanceSnapshot", label: "Finance Balance Snapshot" },
  { apiName: "FinanceTransaction", label: "Finance Transaction" },
  { apiName: "ConsumptionSchedule", label: "Consumption Schedule" },
  { apiName: "ConsumptionRate", label: "Consumption Rate" },

  // Privacy, Consent, Compliance & Identity
  { apiName: "Individual", label: "Individual" },
  { apiName: "Customer", label: "Customer" },
  { apiName: "Seller", label: "Seller" },
  { apiName: "BusinessBrand", label: "Business Brand" },
  { apiName: "ContactPointAddress", label: "Contact Point Address" },
  { apiName: "ContactPointEmail", label: "Contact Point Email" },
  { apiName: "ContactPointPhone", label: "Contact Point Phone" },
  { apiName: "ContactPointConsent", label: "Contact Point Consent" },
  { apiName: "ContactPointTypeConsent", label: "Contact Point Type Consent" },
  { apiName: "PartyConsent", label: "Party Consent" },
  { apiName: "DataUseLegalBasis", label: "Data Use Legal Basis" },
  { apiName: "DataUsePurpose", label: "Data Use Purpose" },
  { apiName: "AuthorizationForm", label: "Authorization Form" },
  { apiName: "AuthorizationFormConsent", label: "Authorization Form Consent" },
  { apiName: "AuthorizationFormDataUse", label: "Authorization Form Data Use" },
  { apiName: "AuthorizationFormText", label: "Authorization Form Text" },
  { apiName: "CommSubscription", label: "Communication Subscription" },
  {
    apiName: "CommSubscriptionChannelType",
    label: "Communication Subscription Channel Type"
  },
  {
    apiName: "CommSubscriptionConsent",
    label: "Communication Subscription Consent"
  },
  {
    apiName: "CommSubscriptionTiming",
    label: "Communication Subscription Timing"
  },
  { apiName: "PrivacyPolicy", label: "Privacy Policy" },
  { apiName: "PrivacyRTBFRequest", label: "Privacy RTBF Request" },

  // Health Cloud & Life Sciences
  { apiName: "CareProgram", label: "Care Program" },
  { apiName: "CareProgramCampaign", label: "Care Program Campaign" },
  { apiName: "CareProgramEnrollee", label: "Care Program Enrollee" },
  { apiName: "CareProgramGoal", label: "Care Program Goal" },
  { apiName: "CareProgramProvider", label: "Care Program Provider" },
  { apiName: "CareProgramTeamMember", label: "Care Program Team Member" },
  { apiName: "CareSpecialty", label: "Care Specialty" },
  {
    apiName: "CareProviderFacilitySpecialty",
    label: "Care Provider Facility Specialty"
  },
  { apiName: "CareTaxonomy", label: "Care Taxonomy" },
  { apiName: "HealthCareDiagnosis", label: "HealthCare Diagnosis" },
  { apiName: "HealthCareProcedure", label: "HealthCare Procedure" },
  { apiName: "HealthCareProvider", label: "HealthCare Provider" },
  { apiName: "HealthCareFacility", label: "HealthCare Facility" },

  // Financial Services Cloud (FSC)
  { apiName: "FinancialAccount", label: "Financial Account" },
  { apiName: "FinancialAccountRole", label: "Financial Account Role" },
  {
    apiName: "FinancialAccountTransaction",
    label: "Financial Account Transaction"
  },
  { apiName: "FinancialGoal", label: "Financial Goal" },
  { apiName: "FinancialHolding", label: "Financial Holding" },
  { apiName: "Securities", label: "Securities" },
  { apiName: "Claim", label: "Claim" },
  { apiName: "InsurancePolicy", label: "Insurance Policy" },
  { apiName: "InsurancePolicyAsset", label: "Insurance Policy Asset" },
  { apiName: "InsurancePolicyCoverage", label: "Insurance Policy Coverage" },
  {
    apiName: "InsurancePolicyParticipant",
    label: "Insurance Policy Participant"
  },

  // Manufacturing & Supply Chain
  { apiName: "SalesAgreement", label: "Sales Agreement" },
  { apiName: "SalesAgreementProduct", label: "Sales Agreement Product" },
  { apiName: "RebateProgram", label: "Rebate Program" },
  { apiName: "RebatePayoutSnapshot", label: "Rebate Payout Snapshot" },

  // Public Sector & Education
  { apiName: "Benefit", label: "Benefit" },
  { apiName: "BenefitAssignment", label: "Benefit Assignment" },
  { apiName: "BenefitDisbursement", label: "Benefit Disbursement" },
  { apiName: "BenefitSchedule", label: "Benefit Schedule" },
  { apiName: "BenefitType", label: "Benefit Type" },
  { apiName: "Program", label: "Program" },
  { apiName: "ProgramEnrollment", label: "Program Enrollment" },
  { apiName: "PublicComplaint", label: "Public Complaint" },

  // Feedback & Operations
  { apiName: "ContactRequest", label: "Contact Request" },
  { apiName: "Survey", label: "Survey" },
  { apiName: "SurveyInvitation", label: "Survey Invitation" },
  { apiName: "SurveyResponse", label: "Survey Response" },
  { apiName: "Location", label: "Location" },
  { apiName: "LocationGroup", label: "Location Group" },
  { apiName: "LocationGroupAssignment", label: "Location Group Assignment" },
  { apiName: "Address", label: "Address" },
  { apiName: "Image", label: "Image" },
  { apiName: "Document", label: "Document" },
  { apiName: "ProcessException", label: "Process Exception" }
];

const targetDir = path.join(
  __dirname,
  "..",
  "force-app",
  "main",
  "default",
  "customMetadata"
);

if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

let count = 0;
const seen = new Set();

for (const obj of standardObjects) {
  if (seen.has(obj.apiName)) continue;
  seen.add(obj.apiName);

  const fileName = `Standard_Object_To_Show_In_Permissions.${obj.apiName}.md-meta.xml`;
  const filePath = path.join(targetDir, fileName);

  const xml = `<?xml version="1.0" encoding="UTF-8" ?>
<CustomMetadata
  xmlns="http://soap.sforce.com/2006/04/metadata"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
>
    <label>${obj.label}</label>
    <protected>false</protected>
    <values>
        <field>Object_API_Name__c</field>
        <value xsi:type="xsd:string">${obj.apiName}</value>
    </values>
</CustomMetadata>
`;

  fs.writeFileSync(filePath, xml, "utf8");
  count++;
}

console.log(
  `Successfully generated ${count} Standard_Object_To_Show_In_Permissions custom metadata records.`
);
