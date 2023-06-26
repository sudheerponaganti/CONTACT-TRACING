({
    fetchStatusCount : function(component) {
        const scope = component.get("v.scope");
        let action = scope === "person" ? component.get("c.getPersonHealthStatusCount") : component.get("c.getLocationHealthStatusCount");
       action.setCallback(this, function(response){
        const state = response.getState();
        if(state === 'SUCCESS'){
            const result = response.getReturnValue();
            component.set("v.count", result);
        }
       });
       $A.enqueueAction(action);
    }
})