# Quick Start Guide - Component Analyzer

This guide will get you up and running with the Component Analyzer in 15 minutes.

## Step-by-Step Deployment

### Prerequisites Check
- [ ] You have Salesforce CLI installed
- [ ] You have VS Code with Salesforce Extensions (or can use Workbench)
- [ ] You have System Administrator access to your Salesforce org
- [ ] Your org has OmniStudio/Vlocity installed

### Method 1: SFDX CLI (Recommended - 5 minutes)

**1. Open Terminal/Command Prompt**

**2. Navigate to the project folder**
```bash
cd salesforce-component-analyzer
```

**3. Authenticate to your org**
```bash
sfdx auth:web:login -a myOrgAlias
```
- A browser window will open
- Log in to your Salesforce org
- Authorize the connection

**4. Deploy to your org**
```bash
sfdx force:source:deploy -p force-app -u myOrgAlias
```

Wait for "Deploy Succeeded" message (usually 30-60 seconds)

**5. Open your org**
```bash
sfdx force:org:open -u myOrgAlias
```

**6. Add the tab to your app**
- Click the App Launcher (waffle icon)
- Click "Edit" on your preferred Lightning app
- Click "Navigation Items"
- Add "Component Analyzer" to the selected items
- Click "Save"

**7. Access the app**
- Click "Component Analyzer" in your app navigation
- The app will load all your components (may take 10-30 seconds first time)

✅ **You're done!**

---

### Method 2: Workbench Deployment (10 minutes)

If you don't have SFDX CLI:

**1. Create a ZIP file**
- Compress the entire `force-app` folder into a ZIP file
- Name it `component-analyzer.zip`

**2. Log in to Workbench**
- Go to https://workbench.developerforce.com/
- Select Environment (Production/Sandbox)
- Accept Terms of Service
- Log in with your Salesforce credentials

**3. Deploy via Workbench**
- Click "Migration" → "Deploy"
- Choose your ZIP file
- Check "Rollback on Error"
- Check "Single Package"
- Click "Next"
- Click "Deploy"
- Wait for deployment to complete (1-2 minutes)

**4. Add to app navigation** (same as Method 1, step 6)

**5. Access the app** (same as Method 1, step 7)

✅ **You're done!**

---

## First Use

### 1. Open Component Analyzer
Click the tab in your app navigation

### 2. Wait for initial load
The app queries all your components. This takes 10-30 seconds depending on org size.

### 3. Explore the interface

**Statistics Cards** (top)
- Shows count of each component type
- Color-coded for easy identification

**Search Bar**
- Type component name, type, or keywords
- Results filter in real-time

**Filter Dropdown**
- Show only specific component types
- Combine with search for precision

**Component List**
- Scroll through all components
- Click any component to see details

### 4. View component details
- Click on any component in the list
- See component metadata
- View dependencies (what it uses and what uses it)

### 5. Export data
- Click "Export CSV" button
- Download complete component inventory
- Open in Excel for further analysis

---

## Common First-Time Issues

### Issue: No components showing up

**Check:**
1. Do you have active OmniScripts/DataRaptors in your org?
   - Go to OmniStudio → OmniScripts
   - Verify components exist

2. Is your namespace correct?
   - The app auto-detects: vlocity_cmt, vlocity_ins, omnistudio
   - If detection fails, you may need to hardcode it (see README)

3. Check permissions
   - Go to Setup → Object Manager
   - Verify you have Read access to:
     - OmniScript__c
     - DRBundle__c
     - OmniProcess__c
     - OmniUiCard__c

### Issue: "Loading" spinner never stops

**Check:**
1. Open browser Developer Console (F12)
2. Check for JavaScript errors
3. Common causes:
   - SOQL query hitting governor limits (unlikely)
   - Permission errors on objects
   - Namespace mismatch

**Solution:**
- Click "Refresh" button
- Clear browser cache and reload
- Check Setup → Apex Jobs for errors

### Issue: Dependencies not showing

This is normal for the first version. Dependencies are calculated from:
- OmniScript PropertySetConfig JSON
- Integration Procedure configuration
- DataRaptor mappings

If a component has no dependencies shown, it may:
- Not call other components
- Have complex JSON that needs enhanced parsing
- Be referenced in ways the parser doesn't check yet

---

## Next Steps

### Customize the app
- Add custom filters
- Modify the UI colors/layout
- Add more component types

### Enhance dependency parsing
- Edit the parser classes to find more relationships
- Add regex patterns for string matching
- Query additional metadata tables

### Create documentation
- Use the app to inventory your components
- Export to CSV
- Share with your team
- Create architecture diagrams

---

## Quick Reference

### Keyboard Shortcuts
- **Ctrl/Cmd + F**: Focus search box (browser default)
- **Escape**: Clear search
- **Click component**: View details
- **Back to List button**: Return to overview

### Export Format
CSV includes:
- Component Type
- Name
- Status (Active/Inactive)
- Description
- Last Modified Date

Import to Excel/Google Sheets for:
- Pivot tables
- Charts
- Additional filtering
- Team sharing

---

## Getting Help

**Deployment Issues:**
- Check Salesforce deployment logs
- Look for "Component Failures" in deploy results
- Common: missing permissions or API version mismatch

**Runtime Issues:**
- Open browser console (F12)
- Check for red errors
- Look at Setup → Debug Logs for Apex errors

**Feature Requests:**
- Document what you need
- Modify the code (it's all included!)
- Share back with your team

---

## Success! 🎉

You now have a powerful tool to:
- ✅ Discover all Salesforce components
- ✅ Understand component relationships
- ✅ Document your architecture
- ✅ Export inventory data
- ✅ Analyze dependencies

**Pro tip:** Schedule a refresh export monthly to track component growth over time.

Happy analyzing!
