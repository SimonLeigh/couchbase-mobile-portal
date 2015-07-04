function getSearchResults(query) {
    var results = {"groups":{}};
    
    if (query.length > 0) {
        var unfilteredResults = {};
        
        var terms = query.match(/[a-zA-Z0-9_\-']*/g);
        var termsCount = 0;
        for (var i=0; i<terms.length; ++i) {
            var term = terms[i];
            if (term == null || term.length == 0) continue;
            
            termsCount++;
            
            for (var index in searchIndex.index) {
                if (index.indexOf(term) == 0) {
                    var docIndexes = searchIndex.index[index];
                    
                    for (var j=0; j<docIndexes.length; ++j) {
                        var docIndex = docIndexes[j][0];
                        var termCount = docIndexes[j][1];
                        
                        var docResults = unfilteredResults[docIndex];
                        if (docResults == null) {
                            unfilteredResults[docIndex] = docResults = {"terms":{},"count":0};
                        }
                        
                        docResults.terms[term] = true;
                        docResults.count += termCount;
                    }
                }
            }
        }
        
        for (var docIndex in unfilteredResults) {
            var docResult = unfilteredResults[docIndex];
            
            if (size(docResult.terms) == termsCount) {
                var doc = searchIndex.docs[docIndex];
                var docLocation = doc[0];
                var docTitle = doc[1];
                var docGroup = searchIndex.groups[doc[2]];
                var termCount = docResult.count;
                
                var group = results;
                for (var k=0; k<docGroup.length; ++k) {
                    var groupTitle = (docGroup[k].length > 0 ? docGroup[k] : "Site");
                    
                    if (group.groups[groupTitle] == null) {
                        group = group.groups[groupTitle] = {
                            "title":groupTitle,
                            "groups":{},
                            "results":{}
                        }
                    } else {
                        group = group.groups[groupTitle];
                    }
                }
                
                var result = group.results[docLocation];
                if (result == null) {
                    result = group.results[docLocation] = {
                        "index":docIndex,
                        "location":docLocation,
                        "title":docTitle,
                        "count":termCount
                    };
                } else {
                    result.count += termCount;
                }
            }
        }
    }
    
    return results;
}