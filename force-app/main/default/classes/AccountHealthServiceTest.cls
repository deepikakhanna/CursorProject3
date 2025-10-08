/**
 * Test class for AccountHealthService
 * Tests all revenue and wins scoring buckets with comprehensive coverage
 */
@IsTest
private class AccountHealthServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts covering all revenue and wins buckets
        List<Account> testAccounts = new List<Account>();
        
        // Account 1: Max score (50 + 50 = 100)
        // Revenue >= 1,000,000 (50 points) + Wins >= 100,000 (50 points)
        testAccounts.add(new Account(
            Name = 'High Revenue High Wins Account',
            AnnualRevenue = 2000000,
            Last_90_Day_Wins__c = 150000
        ));
        
        // Account 2: Medium-high score (30 + 30 = 60)
        // Revenue 250,000-999,999 (30 points) + Wins 25,000-99,999 (30 points)
        testAccounts.add(new Account(
            Name = 'Medium Revenue Medium Wins Account',
            AnnualRevenue = 500000,
            Last_90_Day_Wins__c = 50000
        ));
        
        // Account 3: Low score (10 + 10 = 20)
        // Revenue 1-249,999 (10 points) + Wins 1-24,999 (10 points)
        testAccounts.add(new Account(
            Name = 'Low Revenue Low Wins Account',
            AnnualRevenue = 100000,
            Last_90_Day_Wins__c = 15000
        ));
        
        // Account 4: Zero score (0 + 0 = 0)
        // Revenue null/0 (0 points) + Wins null/0 (0 points)
        testAccounts.add(new Account(
            Name = 'No Revenue No Wins Account',
            AnnualRevenue = 0,
            Last_90_Day_Wins__c = 0
        ));
        
        // Account 5: Mixed score (50 + 10 = 60)
        // Revenue >= 1,000,000 (50 points) + Wins 1-24,999 (10 points)
        testAccounts.add(new Account(
            Name = 'High Revenue Low Wins Account',
            AnnualRevenue = 1500000,
            Last_90_Day_Wins__c = 20000
        ));
        
        // Account 6: Mixed score (10 + 0 = 10)
        // Revenue 1-249,999 (10 points) + Wins null (0 points)
        testAccounts.add(new Account(
            Name = 'Low Revenue No Wins Account',
            AnnualRevenue = 200000,
            Last_90_Day_Wins__c = null
        ));
        
        // Account 7: Edge case - exactly at boundary (30 + 30 = 60)
        // Revenue exactly 250,000 (30 points) + Wins exactly 25,000 (30 points)
        testAccounts.add(new Account(
            Name = 'Boundary Revenue Boundary Wins Account',
            AnnualRevenue = 250000,
            Last_90_Day_Wins__c = 25000
        ));
        
        // Account 8: Edge case - exactly at upper boundary (50 + 50 = 100)
        // Revenue exactly 1,000,000 (50 points) + Wins exactly 100,000 (50 points)
        testAccounts.add(new Account(
            Name = 'Upper Boundary Account',
            AnnualRevenue = 1000000,
            Last_90_Day_Wins__c = 100000
        ));
        
        insert testAccounts;
    }
    
    @IsTest
    static void testUpdateHealthScores_AllScenarios() {
        // Get all test accounts
        List<Account> testAccounts = [
            SELECT Id, Name, AnnualRevenue, Last_90_Day_Wins__c, Health_Score__c 
            FROM Account 
            ORDER BY Name
        ];
        
        // Create set of account IDs
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : testAccounts) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        
        // Call the service method
        AccountHealthService.updateHealthScores(accountIds);
        
        Test.stopTest();
        
        // Query updated accounts
        Map<String, Account> accountsByName = new Map<String, Account>();
        for (Account acc : [
            SELECT Id, Name, AnnualRevenue, Last_90_Day_Wins__c, Health_Score__c 
            FROM Account 
            WHERE Id IN :accountIds
        ]) {
            accountsByName.put(acc.Name, acc);
        }
        
        // Assert health scores for each scenario
        
        // Account 1: Revenue 2,000,000 (50) + Wins 150,000 (50) = 100
        Account highRevHighWins = accountsByName.get('High Revenue High Wins Account');
        System.assertEquals(100, highRevHighWins.Health_Score__c, 
            'High revenue + high wins should equal 100 points');
        
        // Account 2: Revenue 500,000 (30) + Wins 50,000 (30) = 60
        Account medRevMedWins = accountsByName.get('Medium Revenue Medium Wins Account');
        System.assertEquals(60, medRevMedWins.Health_Score__c, 
            'Medium revenue + medium wins should equal 60 points');
        
        // Account 3: Revenue 100,000 (10) + Wins 15,000 (10) = 20
        Account lowRevLowWins = accountsByName.get('Low Revenue Low Wins Account');
        System.assertEquals(20, lowRevLowWins.Health_Score__c, 
            'Low revenue + low wins should equal 20 points');
        
        // Account 4: Revenue 0 (0) + Wins 0 (0) = 0
        Account noRevNoWins = accountsByName.get('No Revenue No Wins Account');
        System.assertEquals(0, noRevNoWins.Health_Score__c, 
            'No revenue + no wins should equal 0 points');
        
        // Account 5: Revenue 1,500,000 (50) + Wins 20,000 (10) = 60
        Account highRevLowWins = accountsByName.get('High Revenue Low Wins Account');
        System.assertEquals(60, highRevLowWins.Health_Score__c, 
            'High revenue + low wins should equal 60 points');
        
        // Account 6: Revenue 200,000 (10) + Wins null (0) = 10
        Account lowRevNoWins = accountsByName.get('Low Revenue No Wins Account');
        System.assertEquals(10, lowRevNoWins.Health_Score__c, 
            'Low revenue + no wins should equal 10 points');
        
        // Account 7: Revenue 250,000 (30) + Wins 25,000 (30) = 60
        Account boundaryAccount = accountsByName.get('Boundary Revenue Boundary Wins Account');
        System.assertEquals(60, boundaryAccount.Health_Score__c, 
            'Boundary revenue + boundary wins should equal 60 points');
        
        // Account 8: Revenue 1,000,000 (50) + Wins 100,000 (50) = 100
        Account upperBoundaryAccount = accountsByName.get('Upper Boundary Account');
        System.assertEquals(100, upperBoundaryAccount.Health_Score__c, 
            'Upper boundary revenue + wins should equal 100 points');
    }
    
    @IsTest
    static void testUpdateHealthScores_EmptySet() {
        Test.startTest();
        
        // Test with empty set - should not throw exception
        AccountHealthService.updateHealthScores(new Set<Id>());
        
        // Test with null set - should not throw exception
        AccountHealthService.updateHealthScores(null);
        
        Test.stopTest();
        
        // No assertions needed - just ensuring no exceptions are thrown
        System.assert(true, 'Empty and null sets should be handled gracefully');
    }
    
    @IsTest
    static void testUpdateHealthScores_SingleAccount() {
        // Create a single account for focused testing
        Account testAccount = new Account(
            Name = 'Single Test Account',
            AnnualRevenue = 750000,  // Should get 30 points
            Last_90_Day_Wins__c = 75000  // Should get 30 points
        );
        insert testAccount;
        
        Test.startTest();
        
        // Call service with single account ID
        AccountHealthService.updateHealthScores(new Set<Id>{testAccount.Id});
        
        Test.stopTest();
        
        // Verify the result
        Account updatedAccount = [
            SELECT Health_Score__c 
            FROM Account 
            WHERE Id = :testAccount.Id
        ];
        
        System.assertEquals(60, updatedAccount.Health_Score__c, 
            'Single account should have correct health score calculated');
    }
    
    @IsTest
    static void testUpdateHealthScores_BulkProcessing() {
        // Create multiple accounts for bulk testing
        List<Account> bulkAccounts = new List<Account>();
        
        for (Integer i = 0; i < 200; i++) {
            bulkAccounts.add(new Account(
                Name = 'Bulk Account ' + i,
                AnnualRevenue = 300000,  // 30 points
                Last_90_Day_Wins__c = 30000  // 30 points
            ));
        }
        insert bulkAccounts;
        
        Set<Id> bulkAccountIds = new Set<Id>();
        for (Account acc : bulkAccounts) {
            bulkAccountIds.add(acc.Id);
        }
        
        Test.startTest();
        
        // Call service with bulk account IDs
        AccountHealthService.updateHealthScores(bulkAccountIds);
        
        Test.stopTest();
        
        // Verify all accounts were updated correctly
        List<Account> updatedAccounts = [
            SELECT Health_Score__c 
            FROM Account 
            WHERE Id IN :bulkAccountIds
        ];
        
        System.assertEquals(200, updatedAccounts.size(), 
            'All bulk accounts should be processed');
        
        for (Account acc : updatedAccounts) {
            System.assertEquals(60, acc.Health_Score__c, 
                'Each bulk account should have correct health score');
        }
    }
}