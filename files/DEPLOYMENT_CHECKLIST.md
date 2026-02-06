# Deployment Checklist - Component Analyzer

Use this checklist to ensure successful deployment and configuration.

## Pre-Deployment

### Environment Verification
- [ ] Confirm target org (Sandbox recommended for first deployment)
- [ ] Verify OmniStudio/Vlocity is installed in the org
- [ ] Confirm you have System Administrator access
- [ ] Check API version compatibility (org supports API 60.0 or higher)

### Tool Requirements
- [ ] SFDX CLI installed (run `sfdx --version` to verify)
- [ ] VS Code with Salesforce Extensions (optional but recommended)
- [ ] Git installed (optional, for version control)

### Backup
- [ ] Export current component list (if replacing existing solution)
- [ ] Create backup of any existing custom Apex classes with similar names
- [ ] Document current org state

## Deployment Steps

### Step 1: Code Review
- [ ] Review all Apex classes for org-specific customizations needed
- [ ] Check namespace prefix matches your org (see NAMESPACE_CONFIGURATION.md)
- [ ] Review security settings (all classes use `with sharing`)
- [ ] Verify API version in meta.xml files

### Step 2: Deploy Code
Choose one method:

#### Method A: SFDX CLI
- [ ] Authenticate to target org: `sfdx auth:web:login -a myOrg`
- [ ] Navigate to project directory
- [ ] Run: `sfdx force:source:deploy -p force-app -u myOrg`
- [ ] Verify "Deploy Succeeded" message
- [ ] Check deployment details for any warnings

#### Method B: Workbench
- [ ] Create ZIP file of force-app directory
- [ ] Log in to workbench.developerforce.com
- [ ] Navigate to Migration → Deploy
- [ ] Upload ZIP file
- [ ] Check "Rollback on Error" and "Single Package"
- [ ] Deploy and monitor progress
- [ ] Review deployment log

#### Method C: Change Set
- [ ] Create outbound change set in source org
- [ ] Add all Apex classes (4 classes)
- [ ] Add LWC component bundle
- [ ] Add Custom Tab
- [ ] Upload to target org
- [ ] Deploy in target org

### Step 3: Post-Deployment Verification
- [ ] All 4 Apex classes deployed successfully
- [ ] LWC component bundle deployed successfully
- [ ] No deployment errors or warnings
- [ ] Check Setup → Apex Classes (should see 4 new classes)
- [ ] Check Setup → Lightning Components (should see componentAnalyzer)

## Configuration

### Step 4: Permissions
- [ ] Create or edit Permission Set
- [ ] Add Read permission for:
  - [ ] vlocity_cmt__OmniScript__c (or your namespace)
  - [ ] vlocity_cmt__DRBundle__c
  - [ ] vlocity_cmt__OmniProcess__c
  - [ ] vlocity_cmt__OmniUiCard__c
  - [ ] FlowDefinitionView
- [ ] Add Apex Class Access:
  - [ ] ComponentAnalyzerController
  - [ ] OmniScriptDependencyParser
  - [ ] IntegrationProcedureDependencyParser
  - [ ] DataRaptorDependencyParser
- [ ] Assign Permission Set to test user

### Step 5: App Configuration
- [ ] Open App Manager (Setup → App Manager)
- [ ] Edit your Lightning app or create new app
- [ ] Add "Component Analyzer" tab to navigation
- [ ] Set visibility (all users, or specific profiles)
- [ ] Save and activate app
- [ ] Assign app to user profiles

### Step 6: Optional - Named Credential (for LWC queries)
If you want to query Lightning Web Components:
- [ ] Setup → Named Credentials → New
- [ ] Name: Salesforce_Tooling_API
- [ ] URL: Your org instance URL
- [ ] Identity Type: Named Principal
- [ ] Authentication: OAuth 2.0
- [ ] Test connection

## Testing

### Step 7: Functional Testing
- [ ] Open Component Analyzer tab
- [ ] Verify app loads without errors
- [ ] Check statistics cards show component counts
- [ ] Verify OmniScripts load (count matches OmniStudio)
- [ ] Verify DataRaptors load
- [ ] Verify Integration Procedures load
- [ ] Verify FlexCards load
- [ ] Verify Flows load

### Step 8: Feature Testing
- [ ] Test search functionality
- [ ] Test filter dropdown
- [ ] Click on a component to view details
- [ ] Verify component details display
- [ ] Check dependencies section (may be empty initially - this is OK)
- [ ] Test "Export CSV" button
- [ ] Test "Refresh" button
- [ ] Test "Back to List" button

### Step 9: Performance Testing
- [ ] Note initial load time (should be 10-30 seconds)
- [ ] Check browser console for errors (F12)
- [ ] Monitor org's API usage (shouldn't spike)
- [ ] Test with large dataset (if org has 100+ components)

### Step 10: User Acceptance Testing
- [ ] Have end users test the interface
- [ ] Verify search meets their needs
- [ ] Confirm export format is useful
- [ ] Gather feedback on UI/UX
- [ ] Document any requested enhancements

## Post-Deployment

### Step 11: Documentation
- [ ] Share QUICKSTART.md with users
- [ ] Create internal wiki page with org-specific instructions
- [ ] Document any namespace hardcoding done
- [ ] Note any customizations made
- [ ] Create user training materials

### Step 12: Monitoring
- [ ] Monitor debug logs for errors (first week)
- [ ] Track user adoption
- [ ] Collect user feedback
- [ ] Note any performance issues
- [ ] Document any bugs found

### Step 13: Maintenance Plan
- [ ] Schedule monthly review of component inventory
- [ ] Plan for future enhancements
- [ ] Assign code ownership/maintenance
- [ ] Set up version control (Git)
- [ ] Create backup of working code

## Rollback Plan

If deployment fails or major issues arise:

### Immediate Rollback
- [ ] Delete Custom Tab (Setup → Tabs)
- [ ] Delete LWC (Setup → Lightning Components)
- [ ] Delete Apex Classes (Setup → Apex Classes)
  - [ ] ComponentAnalyzerController
  - [ ] OmniScriptDependencyParser
  - [ ] IntegrationProcedureDependencyParser
  - [ ] DataRaptorDependencyParser
- [ ] Remove tab from Lightning Apps
- [ ] Remove Permission Set assignments
- [ ] Verify no errors in org

### Alternative: Deactivate Instead of Delete
- [ ] Remove tab from all Lightning Apps
- [ ] Remove Permission Set assignments
- [ ] Keep code in org but inaccessible
- [ ] Allows for quick re-enablement if issues resolved

## Success Criteria

Deployment is successful when:
- [ ] All code deployed without errors
- [ ] Users can access the Component Analyzer tab
- [ ] Component counts display correctly
- [ ] Users can search and filter components
- [ ] Users can view component details
- [ ] Users can export to CSV
- [ ] No errors in debug logs
- [ ] Users report value from the tool

## Troubleshooting Reference

| Issue | Check | Fix |
|-------|-------|-----|
| No components showing | Namespace, Permissions | See NAMESPACE_CONFIGURATION.md |
| Deployment error | API version, Syntax | Check error message, review code |
| Permission error | Object access, Class access | Review Step 4 |
| Slow performance | Component count, Query limits | Expected for large orgs |
| Dependencies not showing | JSON parsing, Component config | Check debug logs |

## Contact and Support

- **Documentation**: See README.md and other docs/ files
- **Issues**: Check debug logs and browser console
- **Namespace Issues**: See NAMESPACE_CONFIGURATION.md
- **Enhancements**: Document in backlog, prioritize with users

---

## Sign-Off

- [ ] Deployment completed by: _________________ Date: _______
- [ ] Testing completed by: _________________ Date: _______
- [ ] Approved for production by: _________________ Date: _______
- [ ] Users notified: _________________ Date: _______

---

## Notes

Document any issues, customizations, or deviations from standard deployment:

_____________________________________________________________
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________
