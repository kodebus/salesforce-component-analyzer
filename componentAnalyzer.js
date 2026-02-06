import { LightningElement, track } from 'lwc';
import getOmniScripts from '@salesforce/apex/ComponentAnalyzerController.getOmniScripts';
import getDataRaptors from '@salesforce/apex/ComponentAnalyzerController.getDataRaptors';
import getIntegrationProcedures from '@salesforce/apex/ComponentAnalyzerController.getIntegrationProcedures';
import getFlexCards from '@salesforce/apex/ComponentAnalyzerController.getFlexCards';
import getLightningWebComponents from '@salesforce/apex/ComponentAnalyzerController.getLightningWebComponents';
import getFlows from '@salesforce/apex/ComponentAnalyzerController.getFlows';
import getComponentDependencies from '@salesforce/apex/ComponentAnalyzerController.getComponentDependencies';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ComponentAnalyzer extends LightningElement {
    @track selectedTab = 'overview';
    @track isLoading = false;
    @track components = {
        omniscripts: [],
        dataraptors: [],
        integrationProcedures: [],
        flexcards: [],
        lwc: [],
        flows: []
    };
    @track selectedComponent = null;
    @track dependencies = null;
    @track searchTerm = '';
    @track filterType = 'all';

    // Component type options for filter
    get componentTypeOptions() {
        return [
            { label: 'All Components', value: 'all' },
            { label: 'OmniScripts', value: 'omniscripts' },
            { label: 'DataRaptors', value: 'dataraptors' },
            { label: 'Integration Procedures', value: 'integrationProcedures' },
            { label: 'FlexCards', value: 'flexcards' },
            { label: 'Lightning Web Components', value: 'lwc' },
            { label: 'Flows', value: 'flows' }
        ];
    }

    // Computed property for filtered components
    get filteredComponents() {
        let allComponents = [];
        
        // Combine all component types with type identifier
        if (this.filterType === 'all' || this.filterType === 'omniscripts') {
            allComponents = [...allComponents, ...this.components.omniscripts.map(c => ({...c, componentType: 'OmniScript'}))];
        }
        if (this.filterType === 'all' || this.filterType === 'dataraptors') {
            allComponents = [...allComponents, ...this.components.dataraptors.map(c => ({...c, componentType: 'DataRaptor'}))];
        }
        if (this.filterType === 'all' || this.filterType === 'integrationProcedures') {
            allComponents = [...allComponents, ...this.components.integrationProcedures.map(c => ({...c, componentType: 'Integration Procedure'}))];
        }
        if (this.filterType === 'all' || this.filterType === 'flexcards') {
            allComponents = [...allComponents, ...this.components.flexcards.map(c => ({...c, componentType: 'FlexCard'}))];
        }
        if (this.filterType === 'all' || this.filterType === 'lwc') {
            allComponents = [...allComponents, ...this.components.lwc.map(c => ({...c, componentType: 'LWC'}))];
        }
        if (this.filterType === 'all' || this.filterType === 'flows') {
            allComponents = [...allComponents, ...this.components.flows.map(c => ({...c, componentType: 'Flow'}))];
        }

        // Apply search filter
        if (this.searchTerm) {
            const searchLower = this.searchTerm.toLowerCase();
            allComponents = allComponents.filter(c => 
                c.name.toLowerCase().includes(searchLower) ||
                (c.description && c.description.toLowerCase().includes(searchLower)) ||
                c.componentType.toLowerCase().includes(searchLower)
            );
        }

        return allComponents;
    }

    // Summary statistics
    get componentStats() {
        return {
            totalComponents: this.components.omniscripts.length + 
                           this.components.dataraptors.length + 
                           this.components.integrationProcedures.length +
                           this.components.flexcards.length +
                           this.components.lwc.length +
                           this.components.flows.length,
            omniscripts: this.components.omniscripts.length,
            dataraptors: this.components.dataraptors.length,
            integrationProcedures: this.components.integrationProcedures.length,
            flexcards: this.components.flexcards.length,
            lwc: this.components.lwc.length,
            flows: this.components.flows.length
        };
    }

    connectedCallback() {
        this.loadAllComponents();
    }

    handleTabChange(event) {
        this.selectedTab = event.target.value;
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleFilterChange(event) {
        this.filterType = event.detail.value;
    }

    handleRefresh() {
        this.loadAllComponents();
    }

    async loadAllComponents() {
        this.isLoading = true;
        try {
            // Load all component types in parallel
            const [omniscripts, dataraptors, integrationProcedures, flexcards, lwc, flows] = await Promise.all([
                getOmniScripts(),
                getDataRaptors(),
                getIntegrationProcedures(),
                getFlexCards(),
                getLightningWebComponents(),
                getFlows()
            ]);

            this.components = {
                omniscripts: omniscripts || [],
                dataraptors: dataraptors || [],
                integrationProcedures: integrationProcedures || [],
                flexcards: flexcards || [],
                lwc: lwc || [],
                flows: flows || []
            };

            this.showToast('Success', 'Components loaded successfully', 'success');
        } catch (error) {
            this.showToast('Error', 'Failed to load components: ' + error.body.message, 'error');
            console.error('Error loading components:', error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleComponentClick(event) {
        const componentId = event.currentTarget.dataset.id;
        const componentType = event.currentTarget.dataset.type;
        
        this.isLoading = true;
        try {
            // Load dependencies for selected component
            this.dependencies = await getComponentDependencies({ 
                componentId: componentId,
                componentType: componentType
            });
            
            // Find and set selected component
            this.selectedComponent = this.filteredComponents.find(c => c.id === componentId);
            this.selectedTab = 'details';
        } catch (error) {
            this.showToast('Error', 'Failed to load component details: ' + error.body.message, 'error');
            console.error('Error loading component details:', error);
        } finally {
            this.isLoading = false;
        }
    }

    handleBackToList() {
        this.selectedComponent = null;
        this.dependencies = null;
        this.selectedTab = 'overview';
    }

    handleExportToCSV() {
        // Create CSV content
        let csv = 'Component Type,Name,Status,Description,Last Modified\n';
        
        this.filteredComponents.forEach(component => {
            csv += `"${component.componentType}","${component.name}","${component.status || 'N/A'}","${component.description || ''}","${component.lastModified || 'N/A'}"\n`;
        });

        // Create download link
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `salesforce_components_${new Date().toISOString().split('T')[0]}.csv`;
        a.click();
        window.URL.revokeObjectURL(url);

        this.showToast('Success', 'Component list exported to CSV', 'success');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Tab visibility getters
    get isOverviewTab() {
        return this.selectedTab === 'overview';
    }

    get isDetailsTab() {
        return this.selectedTab === 'details';
    }

    get isDependencyTab() {
        return this.selectedTab === 'dependencies';
    }
}
