search_init();

function search_init()
{
    var search = document.getElementById("search");
    search.value = getQueryParameter("q");
    search.onchange();
}

function search_onkeyup(element)
{
    if (window.event.keyCode == 27) {
        // Escape.
        element.value = null;
    }
    
    search_onchange(element);
}

function search_onchange(element)
{
    var terms = element.value.toLowerCase();
    var searchResults = document.getElementById("search-results");
    var results = {"groups":{}, "results":{}};
    
    if (terms.length > 0) {
        terms = terms.match(/[a-zA-Z0-9_\-'']*/g);
        
        for (var i=0; i<terms.length; ++i) {
            var term = terms[i];
            if (term == null || term.length == 0) continue;
            
            for (var index in searchIndex.index) {
                if (index.indexOf(term) == 0) {
                    var docIndexes = searchIndex.index[index];
                    
                    for (var j=0; j<docIndexes.length; ++j) {
                        var doc = searchIndex.docs[docIndexes[j][0]];
                        var docLocation = doc[0];
                        var docTitle = doc[1];
                        var docGroup = searchIndex.groups[doc[2]];
                        var termCount = docIndexes[j][1];
                        
                        var group = results;
                        for (var k=0; k<docGroup.length; ++k) {
                            var groupTitle = docGroup[k];
                            
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
                                "location":docLocation,
                                "title":docTitle,
                                "description":searchIndexAdvanced.docDescriptions[j],
                                "count":termCount
                            };
                        } else {
                            result.count += termCount;
                        }
                    }
                }
            }
        }
    }
    
    if (size(results.groups) > 0) {
        var html = "";
        
        for (var group in results.groups) {
            group = results.groups[group];
            
            html += "<div class='group'>";
            html += buildSearchResultGroupHtml(group, 0);
            html += "</div>";
        }
        
        searchResults.innerHTML = html;
    } else {
        searchResults.innerHTML = null;
    }
}

function buildSearchResultGroupHtml(group, depth) {
    var html = "";
    
    if (size(group.results) > 0 || size(group.groups) > 0) {
        var results = new Array();
        for (var result in group.results) {
            results.push(group.results[result]);
        }
        results.sort(function(a, b) {
        if (a.count > b.count) return -1;
            else if (a.count < b.count) return 1;
            else return 0;
        });
        
        for (var i=0; i<results.length; ++i) {
           var result = results[i];
           html += "<h2><a href='" + rootPath + result.location + "'>" + result.title + "</a></h2>";
           html += "<div>" + result.description + "</div>";
           html += "<hr/>";
        }
    }
    
    for (var item in group.groups) {
        html += buildSearchResultGroupHtml(group.groups[item], depth+1);
    }
    
    return html;
}