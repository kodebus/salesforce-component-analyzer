# Salesforce Component Analyzer

A comprehensive Lightning Web Component application for analyzing and documenting Salesforce and OmniStudio components, including dependencies, relationships, and metadata.

## Features

- **Component Discovery**: Automatically finds all OmniScripts, DataRaptors, Integration Procedures, FlexCards, Lightning Web Components, and Flows
- **Dependency Analysis**: Parses component configurations to identify what each component uses and what uses it
- **Interactive Dashboard**: Browse, search, and filter components with a modern, user-friendly interface
- **Export Capabilities**: Export component inventory to CSV for reporting
- **Real-time Statistics**: View summary counts and statistics for all component types
- **Component Details**: Drill down into individual components to see their configuration and dependencies

## What This Solves

Traditional Salesforce reports can't:
- Parse OmniStudio JSON configurations to find dependencies
- Show relationships between components
- Display LWC or Flow metadata
- Provide interactive browsing and filtering

This app solves all those problems by querying metadata directly and presenting it in an easy-to-use interface.

## Architecture

### Components

1. **componentAnalyzer** (LWC)
   - Main UI component with tabs, search, and filtering
   - Displays statistics cards and component list
   - Handles user interactions and navigation

2. **ComponentAnalyzerController** (Apex)
   - Main controller that queries all component types
   - Handles OmniStudio namespace detection (vlocity_cmt, vlocity_ins, omnistudio)
   - Coordinates with dependency parsers

3. **OmniScriptDependencyParser** (Apex)
   - Parses OmniScript PropertySetConfig JSON
   - Finds Integration Procedures, DataRaptors, and Apex classes used
   - Identifies components that embed the OmniScript

4. **IntegrationProcedureDependencyParser** (Apex)
   - Parses Integration Procedure configuration
   - Identifies DataRaptor calls, nested IPs, and REST callouts
   - Finds OmniScripts and other IPs that call this IP

5. **DataRaptorDependencyParser** (Apex)
   - Analyzes DataRaptor mappings
   - Finds Integration Procedures and OmniScripts using the DataRaptor

## Prerequisites

- Salesforce org with OmniStudio installed (Vlocity/Industries package)
- System Administrator or equivalent permissions
- SFDX CLI installed (for deployment)
- VS Code with Salesforce Extensions (recommended)

## Installation

### Option 1: Deploy with SFDX CLI

1. **Clone or download this repository**
   ```bash
   cd salesforce-component-analyzer
   ```

2. **Authenticate to your Salesforce org**
   ```bash
   sfdx auth:web:login -a myOrg
   ```

3. **Deploy the code**
   ```bash
   sfdx force:source:deploy -p force-app -u myOrg
   ```

4. **Assign permissions**
   - Go to Setup → Users → Permission Sets
   - Create a permission set with access to Apex classes and LWC
   - Assign to relevant users

### Option 2: Deploy via Change Set

1. Use the Change Set tool in Salesforce Setup
2. Add all Apex classes and the LWC component bundle
3. Deploy to target org

### Option 3: Manual Deployment via Developer Console

1. **Deploy Apex Classes**
   - Open Developer Console
   - File → New → Apex Class
   - Copy each `.cls` file content and save with the same name

2. **Deploy LWC**
   - This must be done via VS Code + SFDX CLI or Change Sets
   - LWC cannot be created in Developer Console

## Configuration

### 1. OmniStudio Namespace

The app auto-detects your OmniStudio namespace:
- `vlocity_cmt` (Vlocity CMT/Communications)
- `vlocity_ins` (Vlocity Insurance)
- `omnistudio` (newer Industry Cloud installations)

If detection fails, edit the `getNamespacePrefix()` method in each class to hardcode your namespace.

### 2. Tooling API Access (for LWC/Flow queries)

To enable Tooling API queries for Lightning Web Components:

1. **Create a Named Credential**
   - Go to Setup → Named Credentials
   - Click "New Named Credential"
   - **Label**: Salesforce_Tooling_API
   - **Name**: Salesforce_Tooling_API
   - **URL**: `https://yourinstance.my.salesforce.com`
   - **Identity Type**: Named Principal
   - **Authentication Protocol**: OAuth 2.0
   - **Authentication Provider**: Salesforce
   - **Scope**: full refresh_token
   - Save

2. **Alternative**: If Named Credential doesn't work, the app will gracefully skip LWC queries

### 3. Add to App Navigation

1. Go to Setup → App Manager
2. Edit your Lightning app (or create a new one)
3. Add the "Component Analyzer" tab to the navigation menu
4. Save and assign to user profiles

## Usage

### Accessing the App

1. **Via Tab**: Click the "Component Analyzer" tab in your app navigation
2. **Via App Builder**: Add the component to any Lightning App page
3. **Via Home Page**: Add to your Lightning Home page

### Features

#### Overview Tab
- **Statistics Cards**: See counts for each component type
- **Search**: Filter components by name, type, or description
- **Filter Dropdown**: Show only specific component types
- **Component List**: Click any component to see details
- **Export Button**: Download component inventory as CSV
- **Refresh Button**: Reload all component data

#### Component Details Tab
- **Component Information**: View metadata and configuration
- **Dependencies Section**: 
  - **Uses**: What this component calls/references
  - **Used By**: What components call/reference this one

### Search Tips

- Search is case-insensitive
- Searches across name, type, and description fields
- Combine search with type filter for precise results

## Extending the App

### Adding More Component Types

To add support for additional Salesforce components:

1. **Add a new getter method** in `ComponentAnalyzerController.cls`:
   ```apex
   @AuraEnabled(cacheable=false)
   public static List<ComponentWrapper> getCustomComponents() {
       // Query your component type
       // Return wrapped data
   }
   ```

2. **Call it from the LWC** in `componentAnalyzer.js`:
   ```javascript
   import getCustomComponents from '@salesforce/apex/ComponentAnalyzerController.getCustomComponents';
   
   // Add to loadAllComponents() Promise.all array
   ```

3. **Update the UI** to display and filter the new type

### Enhancing Dependency Parsing

The dependency parsers can be enhanced to find more relationships:

1. **Parse more JSON fields** in PropertySetConfig
2. **Query related objects** (e.g., ContentVersion for Experience pages)
3. **Use Tooling API** to query metadata relationships
4. **Add regex patterns** to find string-based references

Example enhancement in `OmniScriptDependencyParser.cls`:
```apex
// Look for FlexCard references
if (config.containsKey('cardName')) {
    String cardName = (String)config.get('cardName');
    uses.add('FlexCard: ' + cardName);
}
```

### Custom Metadata Documentation

Add a custom object to store component documentation:

1. Create `Component_Documentation__c` custom object with fields:
   - Component_Id__c (Text)
   - Component_Type__c (Picklist)
   - Purpose__c (Long Text Area)
   - Technical_Notes__c (Long Text Area)
   - Business_Owner__c (Lookup to User)

2. Enhance the LWC to display and edit this documentation

3. Add an Apex method to save documentation

## Troubleshooting

### Issue: "No components found"

**Cause**: Namespace detection failed or no OmniStudio components exist

**Solution**: 
- Verify OmniStudio is installed
- Check that you have components in your org
- Manually set namespace in `getNamespacePrefix()` methods

### Issue: "Error retrieving components"

**Cause**: Missing object permissions

**Solution**:
- Verify user has Read access to:
  - OmniScript__c
  - DRBundle__c
  - OmniProcess__c
  - OmniUiCard__c
  - FlowDefinitionView (standard object)

### Issue: "Dependencies not showing"

**Cause**: JSON parsing issues or inactive components

**Solution**:
- Check browser console for errors
- Verify PropertySetConfig fields are populated
- Ensure components are Active

### Issue: "LWC components not loading"

**Cause**: Tooling API access not configured

**Solution**:
- This is expected if Named Credential isn't set up
- App will work without LWC data
- Follow "Tooling API Access" setup steps to enable

## Performance Considerations

- **Large Orgs**: Queries may take 10-30 seconds with 100+ components
- **Caching**: Consider adding `cacheable=true` to @AuraEnabled methods if data rarely changes
- **Selective Queries**: Add WHERE clauses to limit results if needed
- **Pagination**: For orgs with 500+ components, implement pagination in the LWC

## Security Notes

- All queries use `with sharing` to respect user permissions
- Users can only see components they have access to
- No DML operations are performed (read-only)
- Named Credentials protect API credentials

## Roadmap / Future Enhancements

- [ ] Visual dependency graph using D3.js or similar
- [ ] Bulk documentation editing interface
- [ ] Version comparison for OmniStudio components
- [ ] Export dependencies as diagram (Mermaid, PlantUML)
- [ ] Integration with Salesforce Change Sets
- [ ] Automated documentation generation
- [ ] Component usage analytics
- [ ] Scheduled email reports

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review Salesforce debug logs
3. Check browser console for JavaScript errors
4. Verify all prerequisites are met

## Contributing

To contribute enhancements:
1. Test thoroughly in a sandbox
2. Document any new configuration requirements
3. Update this README with new features
4. Ensure code follows Salesforce best practices

## License

This component is provided as-is for use in your Salesforce org. Modify and extend as needed for your use case.

## Version History

- **v1.0** (2024) - Initial release
  - Basic component listing
  - Dependency parsing for OmniStudio
  - Export to CSV
  - Search and filter capabilities
