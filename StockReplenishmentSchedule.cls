global class StockReplenishmentSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        
        StockReplenishmentBatch stockReplenishmentBatch = new StockReplenishmentBatch();
        Database.executeBatch(stockReplenishmentBatch, 1);
    }
    
}