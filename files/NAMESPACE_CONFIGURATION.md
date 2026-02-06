# OmniStudio Namespace Configuration Guide

The Component Analyzer needs to know which OmniStudio namespace your org uses. This guide helps you configure it correctly.

## Understanding OmniStudio Namespaces

Depending on when and how OmniStudio/Vlocity was installed, your org will use one of these namespaces:

| Namespace | Product | Typical Orgs |
|-----------|---------|--------------|
| `vlocity_cmt__` | Vlocity Communications | Telecoms, Media |
| `vlocity_ins__` | Vlocity Insurance | Insurance companies |
| `omnistudio__` | OmniStudio (newer) | Industry Cloud, newer installs |

## How the App Detects Your Namespace

The app automatically tries each namespace in order:
1. First tries `vlocity_cmt__`
2. Then tries `vlocity_ins__`
3. Then tries `omnistudio__`
4. Falls back to `vlocity_cmt__` as default

This happens in the `getNamespacePrefix()` method in each parser class.

## Verifying Your Namespace

### Option 1: Check in Setup

1. Go to **Setup** → **Object Manager**
2. Search for "OmniScript"
3. Look at the API name:
   - `vlocity_cmt__OmniScript__c` = vlocity_cmt
   - `vlocity_ins__OmniScript__c` = vlocity_ins
   - `omnistudio__OmniScript__c` = omnistudio

### Option 2: Developer Console Query

1. Open **Developer Console**
2. Click **Query Editor**
3. Try each query until one works:

```sql
-- Try vlocity_cmt
SELECT Id FROM vlocity_cmt__OmniScript__c LIMIT 1

-- Try vlocity_ins
SELECT Id FROM vlocity_ins__OmniScript__c LIMIT 1

-- Try omnistudio
SELECT Id FROM omnistudio__OmniScript__c LIMIT 1
```

The query that returns results (not an error) is your namespace.

## When Auto-Detection Fails

If the app shows "No components found" but you know you have OmniStudio components, the auto-detection may have failed.

### Solution: Hardcode Your Namespace

Edit each of these files and replace the `getNamespacePrefix()` method:

**Files to edit:**
1. `ComponentAnalyzerController.cls`
2. `OmniScriptDependencyParser.cls`
3. `IntegrationProcedureDependencyParser.cls`
4. `DataRaptorDependencyParser.cls`

**Replace this method:**
```apex
private static String getNamespacePrefix() {
    try {
        Database.query('SELECT Id FROM vlocity_cmt__OmniScript__c LIMIT 1');
        return 'vlocity_cmt__';
    } catch (Exception e) {}
    
    try {
        Database.query('SELECT Id FROM vlocity_ins__OmniScript__c LIMIT 1');
        return 'vlocity_ins__';
    } catch (Exception e) {}
    
    try {
        Database.query('SELECT Id FROM omnistudio__OmniScript__c LIMIT 1');
        return 'omnistudio__';
    } catch (Exception e) {}
    
    return 'vlocity_cmt__';
}
```

**With this simplified version** (example for vlocity_ins):
```apex
private static String getNamespacePrefix() {
    return 'vlocity_ins__';  // <-- Your namespace here
}
```

### Steps to Update

1. **Identify your namespace** (see above)

2. **Open Developer Console** or VS Code

3. **Edit each class**
   - Open the class
   - Find `getNamespacePrefix()` method
   - Replace with hardcoded version
   - Change `'vlocity_ins__'` to your namespace
   - Save

4. **Redeploy** if using VS Code:
   ```bash
   sfdx force:source:deploy -p force-app/main/default/classes
   ```

5. **Refresh the Component Analyzer** tab

## Advanced: Multiple Namespaces (Rare)

Some orgs might have multiple products installed. If you need to support multiple namespaces:

### Option 1: Separate Queries
```apex
@AuraEnabled(cacheable=false)
public static List<ComponentWrapper> getOmniScripts() {
    List<ComponentWrapper> components = new List<ComponentWrapper>();
    
    // Try each namespace
    String[] namespaces = new String[]{'vlocity_cmt__', 'vlocity_ins__', 'omnistudio__'};
    
    for (String namespace : namespaces) {
        try {
            String query = 'SELECT Id, Name FROM ' + namespace + 'OmniScript__c';
            List<SObject> records = Database.query(query);
            // Process records...
        } catch (Exception e) {
            // Namespace not present, continue
        }
    }
    
    return components;
}
```

### Option 2: Custom Setting
Create a custom setting to store the namespace:

1. **Create Custom Setting**
   - Setup → Custom Settings
   - New → Name: "OmniStudio_Config"
   - Add field: Namespace__c (Text)

2. **Manage Custom Setting**
   - Click "Manage"
   - New
   - Set Namespace__c = 'vlocity_cmt__' (or your namespace)
   - Save

3. **Update Code**
```apex
private static String getNamespacePrefix() {
    OmniStudio_Config__c config = OmniStudio_Config__c.getInstance();
    if (config != null && String.isNotBlank(config.Namespace__c)) {
        return config.Namespace__c;
    }
    return 'vlocity_cmt__'; // fallback
}
```

## Troubleshooting

### Issue: "Invalid Object" error in logs

**Meaning:** The query is using the wrong namespace prefix

**Solution:** 
- Verify your namespace (see "Verifying Your Namespace" above)
- Hardcode the correct namespace in all 4 classes
- Redeploy

### Issue: Some components show, others don't

**Meaning:** Mixed namespace or partial deployment

**Check:**
1. Are all your OmniStudio components on the same namespace?
2. Did all 4 Apex classes deploy successfully?
3. Check Setup → Apex Classes → ensure all 4 are present

### Issue: Components load but dependencies don't

**Meaning:** JSON parsing may need adjustment for your namespace's format

**Solution:**
- OmniStudio JSON structure varies slightly between versions
- You may need to customize the parser classes
- Check browser console for JavaScript errors
- Check debug logs for Apex errors

## Testing Your Configuration

After deployment, test with this checklist:

- [ ] App loads without errors
- [ ] Statistics cards show non-zero numbers
- [ ] You can see your OmniScripts listed
- [ ] You can see your DataRaptors listed
- [ ] You can see your Integration Procedures
- [ ] You can see your FlexCards
- [ ] Clicking a component shows details
- [ ] Export CSV button works

If any items fail, review the namespace configuration.

## Need More Help?

1. **Check Object Manager** in Setup to verify object API names
2. **Run SOQL queries** in Developer Console to test access
3. **Check Debug Logs** for specific error messages
4. **Review permissions** on OmniStudio objects
5. **Verify API version** compatibility (app uses API 60.0)

---

## Quick Reference Table

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| "No components found" | Wrong namespace | Verify and hardcode namespace |
| Some components missing | Partial namespace match | Check all 4 classes |
| Error loading components | Permission issue | Verify object permissions |
| Dependencies not showing | JSON parsing issue | Check debug logs |
| Slow loading | Too many components | Expected for large orgs |

---

## Version Compatibility

| OmniStudio Version | Namespace | Status |
|-------------------|-----------|--------|
| Vlocity CMT (all versions) | vlocity_cmt__ | ✅ Supported |
| Vlocity Insurance (all versions) | vlocity_ins__ | ✅ Supported |
| OmniStudio 2020+ | omnistudio__ | ✅ Supported |
| Industries Cloud | omnistudio__ | ✅ Supported |

All versions work with the auto-detection. Hardcoding is only needed if auto-detection fails.
