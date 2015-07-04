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
    var query = element.value.toLowerCase();
    var results = getSearchResults(query);
    
    var searchResults = document.getElementById("search-results");
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
        var html = "";
        
        html += "<div class='group'>";
        html += "<div class='item'>No results found.</div>";
        html += "</div>";
        
        searchResults.innerHTML = html;
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
           var description = searchIndexAdvanced.docDescriptions[result.index];
           
           html += "<div class='item'>";
               html += "<div class='title'><a href='" + rootPath + result.location + "'>" + result.title + "</a></div>";
               html += "<div class='description'>" + description + "</div>";
               html += "<div class='location'>" + result.location + "</div>";
           html += "</div>";
        }
    }
    
    for (var item in group.groups) {
        html += buildSearchResultGroupHtml(group.groups[item], depth+1);
    }
    
    return html;
}