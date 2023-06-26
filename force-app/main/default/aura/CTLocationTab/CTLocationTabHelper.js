({
    fetchLocationInformation: function (component) {
        const recordId = component.get("v.recordId");
        let action = component.get("c.getLocationDetails");
        action.setParams({
            recordId
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const resp = response.getReturnValue();
                if (!resp || !resp.name) {
                    component.set("v.locationFound", false);
                    this.showToast("ERROR", "Please Enter a valid location id", "error");

                } else {
                    component.set("v.locationFound", true);
                    component.set("v.locationInfo", resp);
                }
            } else {
                component.set("v.locationFound", false);
                this.showToast("ERROR", "Please Enter a valid location id", "error");
            }
        });

        $A.enqueueAction(action);
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }
})