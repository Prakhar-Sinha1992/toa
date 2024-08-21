trigger RestaurantLocationTrigger on Restaurant_Location__c (before insert,after insert, after update,after delete)
{
    new RestaurantLocationTriggerHandler().run();
}