({  
    showToastErr : function(component,event,toastErrorMsg){
  		
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
            "title": "Error!",
            "type": "error",
            "message": toastErrorMsg
        });
        resultsToast.fire();
 	},
	getCFPicklist : function(component, event, helper) {
        var action = component.get("c.getDocTypePicklist");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var typeMap = [];
                for(var key in result ){
                    typeMap.push({key:key,value:result[key]});  
                }
                component.set("v.docTypes", typeMap);
            }
        });
        $A.enqueueAction(action);
	},
    getStatusPicklist : function(component, event, helper) {
        var action = component.get("c.getDocStatusPicklist");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var typeMap = [];
                for(var key in result ){
                    typeMap.push({key:key,value:result[key]});  
                }
                component.set("v.docStatus", typeMap);
            }
        });
        $A.enqueueAction(action);
	},
    getCLFRMPicklist : function(component, event, helper) {
        var action = component.get("c.getCLFPicklist");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var typeMap = [];
                for(var key in result ){
                    typeMap.push({key:key,value:result[key]});  
                }
                component.set("v.docCF", typeMap);
            }
        });
        $A.enqueueAction(action);
	}
})