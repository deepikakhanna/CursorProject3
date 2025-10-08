/**
 * Service class for calculating and updating Account Health Scores
 * Health Score is calculated based on Annual Revenue and Last 90 Day Wins
 */
public with sharing class AccountHealthService {
    
    /**
     * Updates Health Scores for the specified Account records
     * @param accountIds Set of Account IDs to update
     */
    public static void updateHealthScores(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        
        // Query Account records with required fields
        List<Account> accountsToUpdate = [
            SELECT Id, AnnualRevenue, Last_90_Day_Wins__c, Health_Score__c
            FROM Account 
            WHERE Id IN :accountIds
        ];
        
        // Calculate health scores for each account
        for (Account acc : accountsToUpdate) {
            Integer revenueScore = calculateRevenueScore(acc.AnnualRevenue);
            Integer recentWinsScore = calculateRecentWinsScore(acc.Last_90_Day_Wins__c);
            acc.Health_Score__c = revenueScore + recentWinsScore;
        }
        
        // Update the accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    /**
     * Calculates Revenue Score based on Annual Revenue
     * Scoring rules:
     * - If AnnualRevenue is null or 0 → 0 points
     * - If AnnualRevenue > 0 and < 250,000 → 10 points
     * - If AnnualRevenue >= 250,000 and < 1,000,000 → 30 points
     * - If AnnualRevenue >= 1,000,000 → 50 points
     * @param annualRevenue The annual revenue amount
     * @return Integer score based on revenue
     */
    private static Integer calculateRevenueScore(Decimal annualRevenue) {
        if (annualRevenue == null || annualRevenue == 0) {
            return 0;
        } else if (annualRevenue > 0 && annualRevenue < 250000) {
            return 10;
        } else if (annualRevenue >= 250000 && annualRevenue < 1000000) {
            return 30;
        } else if (annualRevenue >= 1000000) {
            return 50;
        }
        return 0;
    }
    
    /**
     * Calculates Recent Wins Score based on Last 90 Day Wins
     * Scoring rules:
     * - If Last_90_Day_Wins__c is null or 0 → 0 points
     * - If Last_90_Day_Wins__c > 0 and < 25,000 → 10 points
     * - If Last_90_Day_Wins__c >= 25,000 and < 100,000 → 30 points
     * - If Last_90_Day_Wins__c >= 100,000 → 50 points
     * @param last90DayWins The last 90 day wins amount
     * @return Integer score based on recent wins
     */
    private static Integer calculateRecentWinsScore(Decimal last90DayWins) {
        if (last90DayWins == null || last90DayWins == 0) {
            return 0;
        } else if (last90DayWins > 0 && last90DayWins < 25000) {
            return 10;
        } else if (last90DayWins >= 25000 && last90DayWins < 100000) {
            return 30;
        } else if (last90DayWins >= 100000) {
            return 50;
        }
        return 0;
    }
}