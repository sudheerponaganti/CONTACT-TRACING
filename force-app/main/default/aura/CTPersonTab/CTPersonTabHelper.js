({
    fetchUserInformation : function(component) {
  const recordId = component.get("v.recordId");
  let action = component.get("c.getPersonDetails");
  action.setParams({
    recordId 
  });
  action.setCallback(this,function(response){
    const state = response.getState();
    if(state === 'SUCCESS'){
        const resp = response.getReturnValue();
        if(!resp || !resp.name){
            component.set("v.userFound", false);
            this.showToast("ERROR","Please enter a valid user id","error"); 
        }else{
            component.set("v.userFound", true);
            component.set("v.userInfo",resp);
        }
    }else{
        component.set("v.userFound", false);
        this.showToast("ERROR","Please Enter a valid user id","error");
    }
  });

  $A.enqueueAction(action);
    },

    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
           title,
           message,
           type
        });
        toastEvent.fire();
    }
})