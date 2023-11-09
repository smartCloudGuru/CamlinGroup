/*
 * Created by Oleg Bogdanovych on 10/16/2019.
 */
public without sharing class ExtendedWarrantyController {
	@AuraEnabled
	public static List<AssetWrapper> getAssets(String warrantyId) {
		Extended_Warranty__c ew = [SELECT Id, Account__c, Start_Date__c, End_Date__c FROM Extended_Warranty__c WHERE Id = :warrantyId];

		List<Extended_Warranty__c> activeWarranties = [
			SELECT
				Id, Account__c, Start_Date__c, End_Date__c, (SELECT Id, Asset__c FROM Extended_Warranty_Items__r)
			FROM
				Extended_Warranty__c
			WHERE Id != :warrantyId
                 AND Account__c = :ew.Account__c
					AND ((Start_Date__c >= :ew.End_Date__c AND Start_Date__c <= :ew.End_Date__c)
							OR (End_Date__c >= :ew.Start_Date__c AND End_Date__c <= :ew.End_Date__c)
							OR (Start_Date__c < :ew.Start_Date__c AND End_Date__c > :ew.End_Date__c)
                        	OR (Start_Date__c < :ew.End_Date__c AND Start_Date__c > :ew.Start_Date__c))
		];

		Set<Id> assetsToExclude = new Set<Id>();
		for (Extended_Warranty__c eWarranty : activeWarranties) {
			for (Extended_Warranty_Item__c ewi : eWarranty.Extended_Warranty_Items__r) {
					assetsToExclude.add(ewi.Asset__c);
			}
		}

		List<Asset> assets = [
			SELECT
				Id, Name, Product2Id, Product2.Name, Product2.ProductCode
			FROM Asset
			WHERE AccountId = :ew.Account__c
				AND Id NOT IN :assetsToExclude
            LIMIT 10
		];

		Set<Id> existingAssets = new Set<Id>();
		for (Extended_Warranty_Item__c ewi : [SELECT Id, Asset__c FROM Extended_Warranty_Item__c WHERE Extended_Warranty__c = :warrantyId]) {
			existingAssets.add(ewi.Asset__c);
		}

		List<AssetWrapper> assetWrappers = new List<AssetWrapper>();
		for (Asset a : assets) {
			AssetWrapper aw = new AssetWrapper(a);
			if (existingAssets.contains(a.Id)) {
				aw.isMapped = true;
				aw.isSelected = true;
			}

			assetWrappers.add(aw);
		}

		return assetWrappers;
	}

	@AuraEnabled
	public static List<AssetWrapper> getSelectedAssets(String warrantyId) {
		Extended_Warranty__c ew = [
			SELECT 
				Id, Account__c, Start_Date__c, End_Date__c, (SELECT Id, Asset__c FROM Extended_Warranty_Items__r ORDER BY Name) 
			FROM 
				Extended_Warranty__c 
			WHERE 
				Id = :warrantyId
		];

		Set<Id> selectedAssetsIds = new Set<Id>(); 

		for (Extended_Warranty_Item__c item : ew.Extended_Warranty_Items__r) {
			selectedAssetsIds.add(item.Asset__c);
		}

		List<Asset> selectedAssets = [SELECT Id, Name, Product2.ProductCode FROM Asset WHERE Id IN :selectedAssetsIds];

		List<AssetWrapper> assetWrappers = new List<AssetWrapper>();
		for (Asset a : selectedAssets) {
			AssetWrapper aw = new AssetWrapper(a);
			aw.isMapped = true;   
			aw.isSelected = true;
		
			assetWrappers.add(aw);
		}


		return assetWrappers;
	}

	@AuraEnabled
	public static List<AssetWrapper> getAvailableAssets(String warrantyId, String startDate, String endDate) {
		
		Date itemStartDate = Date.valueOf(startDate);
		Date itemEndDate = Date.valueOf(endDate);
		
		Extended_Warranty__c ew = [SELECT Id, Account__c, Start_Date__c, End_Date__c FROM Extended_Warranty__c WHERE Id = :warrantyId];

		/*List<Extended_Warranty__c> activeWarranties = [
			SELECT
				Id, Account__c, Start_Date__c, End_Date__c, (SELECT Id, Asset__c FROM Extended_Warranty_Items__r)
			FROM
				Extended_Warranty__c
			WHERE Id != :warrantyId
                 AND Account__c = :ew.Account__c
					AND ((Start_Date__c >= :ew.End_Date__c AND Start_Date__c <= :ew.End_Date__c)
							OR (End_Date__c >= :ew.Start_Date__c AND End_Date__c <= :ew.End_Date__c)
							OR (Start_Date__c < :ew.Start_Date__c AND End_Date__c > :ew.End_Date__c)
                        	OR (Start_Date__c < :ew.End_Date__c AND Start_Date__c > :ew.Start_Date__c))
		];*/

		/*Map<Id, Extended_Warranty__c> activeWarranties = new Map<Id, Extended_Warranty__c>([
			SELECT
				Id, Account__c, Start_Date__c, End_Date__c, (SELECT Id, Asset__c FROM Extended_Warranty_Items__r)
			FROM
				Extended_Warranty__c
			WHERE
                Account__c = :ew.Account__c
				AND ((Start_Date__c >= :ew.End_Date__c AND Start_Date__c <= :ew.End_Date__c)
						OR (End_Date__c >= :ew.Start_Date__c AND End_Date__c <= :ew.End_Date__c)
						OR (Start_Date__c < :ew.Start_Date__c AND End_Date__c > :ew.End_Date__c)
                        OR (Start_Date__c < :ew.End_Date__c AND Start_Date__c > :ew.Start_Date__c))
		]);*/

		Map<Id, Extended_Warranty__c> activeWarranties = new Map<Id, Extended_Warranty__c>([
			SELECT
				Id, Account__c, Start_Date__c, End_Date__c, 
				(SELECT Id, Asset__c, Start_Date__c, End_Date__c FROM Extended_Warranty_Items__r)
			FROM
				Extended_Warranty__c
			WHERE
                Account__c = :ew.Account__c
		]);

		activeWarranties.remove(warrantyId);
		
		Set<Id> assetsToExclude = new Set<Id>();
		for (Id eWarrantyId : activeWarranties.keySet()) {
			for (Extended_Warranty_Item__c ewi : activeWarranties.get(eWarrantyId).Extended_Warranty_Items__r) {
				if ((ewi.Start_Date__c <= itemStartDate && ewi.End_Date__c >= itemEndDate) ||
					(ewi.Start_Date__c >= itemStartDate && ewi.Start_Date__c <= itemEndDate) ||
					(ewi.End_Date__c >= itemStartDate && ewi.End_Date__c <= itemEndDate)) {
					assetsToExclude.add(ewi.Asset__c);
				}	
			}
		}
		
		List<Asset> assets = [
			SELECT
				Id, Name, Product2Id, Product2.Name, Product2.ProductCode
			FROM Asset
			WHERE AccountId = :ew.Account__c
				AND Id NOT IN :assetsToExclude
				ORDER BY Name
		];

		Set<Id> existingAssets = new Set<Id>();
		for (Extended_Warranty_Item__c ewi : [SELECT Id, Asset__c FROM Extended_Warranty_Item__c WHERE Extended_Warranty__c = :warrantyId]) {
			existingAssets.add(ewi.Asset__c);
		}

		List<AssetWrapper> assetWrappers = new List<AssetWrapper>();
		for (Asset a : assets) {
			AssetWrapper aw = new AssetWrapper(a);
			if (existingAssets.contains(a.Id)) {
				aw.isMapped = true;
				aw.isSelected = true;
			}
			
			assetWrappers.add(aw);
		}
		System.debug('aw.size: ' + assetWrappers.size());
		return assetWrappers;
	}

	@AuraEnabled
	public static void saveWarrantyItems(String warrantyId, String assetsStr, String startDate, String endDate) {
		List<AssetWrapper> assets = (List<AssetWrapper>)JSON.deserialize(assetsStr, List<AssetWrapper>.class);

		Date itemStartDate = null;
		Date itemEndDate = null; 

		if (startDate != '' && startDate != null && endDate != '' && endDate != null) {
			itemStartDate = Date.valueOf(startDate);
			itemEndDate = Date.valueOf(endDate); 
		}

		Set<Id> unMappedAssets = new Set<Id>();
		List<Extended_Warranty_Item__c> toInsert = new List<Extended_Warranty_Item__c>();

		for (AssetWrapper aw : assets) {
			if (aw.isSelected == true && aw.isMapped == false) {
				Extended_Warranty_Item__c ewi = new Extended_Warranty_Item__c(
					Asset__c = aw.assetId,
					Extended_Warranty__c = warrantyId,
					Start_Date__c = itemStartDate,
					End_Date__c = itemEndDate
				);

				toInsert.add(ewi);
			} else if (aw.isSelected == false && aw.isMapped == true) {
				unMappedAssets.add(aw.assetId);
			}
		}

		try {
			if (!toInsert.isEmpty()) {
				insert toInsert;
			}
		} catch (Exception e) {
			throw new AuraHandledException('Something went wrong on inserting new records! ' + e.getMessage());
		}

		try {
			if (!unMappedAssets.isEmpty()) {
				List<Extended_Warranty_Item__c> toDelete = [SELECT Id FROM Extended_Warranty_Item__c WHERE Asset__c IN :unMappedAssets AND Extended_Warranty__c = :warrantyId];
				delete toDelete;
			}
		} catch (Exception e) {
			throw new AuraHandledException('Something went wrong on deleting warranty relations! ' + e.getMessage());
		}
	}

	public class AssetWrapper {
		@AuraEnabled
		public String assetId {get; set;}

		@AuraEnabled
		public Boolean isSelected {get; set;}

		@AuraEnabled
		public Boolean isMapped {get; set;}

		@AuraEnabled
		public String assetName {get; set;}

		@AuraEnabled
		public String assetCode {get; set;}

		@AuraEnabled
		public Boolean isChanged {get; set;}

		public AssetWrapper(Asset a) {
			this.assetId = a.Id;
			this.assetName = a.Name;
			this.assetCode = a.Product2.ProductCode;
			this.isSelected = false;
			this.isMapped = false;
			this.isChanged = false;
		}
	}
}