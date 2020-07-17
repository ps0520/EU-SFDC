/*
@Author        : Kumar Navneet
@Date Created    : 09/01/2020
@Description    : Batch class 
****************************************************************************************/
global class TestPublishEventBatchClass implements Database.Batchable<Sobject>, Database.AllowsCallouts {
   
    global Database.QueryLocator start(Database.BatchableContext BC){
        String orderType = 'IE%' ;
        String query = 'SELECT id, status, type from order ';
               query+= ' where status = \'Activated\'' ;  
               query+= String.isNotBlank(orderType) && String.isNotEmpty(orderType) ? ' AND Type LIKE: orderType ': '';
             //  query+= ' AND Id = \'8011n00000WF5cmAAD\'' ;         
                 query+= ' Limit 30 ';
        	  
        system.debug('start' + query);                
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Order> scope){ 
        List<Order> Uporder = new List<Order>();
        for(Order o : scope){
                  o.Status = 'Open'; 
                  Uporder.add(o);
                }    update Uporder;
    }
    global void finish(Database.BatchableContext BC){
        system.debug('Order Finish: ');    }
}