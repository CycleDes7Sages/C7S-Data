xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

          
          

declare function local:update-div-ids($doc as document-node()) as document-node() {
(:  in progress, does not work  :)
  let $updated-divs := for $div in $doc//tei:div[tei:head[@n]]
    return
      element { node-name($div) } {
        $div/@* except $div/@xml:id,
        attribute xml:id { $div/tei:head/@n },
        $div/node()
      }
 let $updated-ps := for $p in $doc//tei:p[@n]
    return
      element { node-name($p) } {
        $p/@* except $p/@xml:id,
        attribute xml:id { $p/@n },
        $p/node()
      }
  return
    document {
      element { node-name($doc/*) } {
        $doc/*/@*,
        for $node in $doc/*/node()
        return
          if ($node instance of element() and node-name($node) = xs:QName("tei:div")) then
            $updated-divs[1]
          else
        if ($node instance of element() and node-name($node) = xs:QName("tei:p")) then
            $updated-ps[1]
          else
            $node
      }
    }
};

declare function local:create-path($file-path as xs:string, $base-path as xs:string, $target-path as xs:string, $content) {
    let $relative-path := substring-after($file-path, $base-path)
    let $segments := tokenize(substring($relative-path, 2), "/") (: usuwa początkowy "/" :)
    let $base := ""
    return

    for $i in 1 to count($segments) - 1
        let $current := $target-path || "/" || string-join(subsequence($segments, 1, $i), "/")
        return (
          if (xmldb:collection-available($current)) then ()
          else xmldb:create-collection($target-path || "/" || string-join(subsequence($segments, 1, $i - 1), "/"), $segments[$i]),
          if ($i = count($segments) - 1) then  
              xmldb:store($current, $segments[$i +1], $content)
              else ()
        )
          

    
};
    


let $collection-path := "/db/apps/C7S-data"
let $collection := collection("/db/apps/C7S-data/data")
let $target-path := "data-converted"


let $root := if (xmldb:collection-available($target-path)) then ()
      else xmldb:create-collection($collection-path, $target-path)



return
for $doc in $collection
let $new-document := local:update-div-ids($doc)
return 
      local:create-path(document-uri($doc), "/db/apps/C7S-data/data", "/db/apps/C7S-data/data-converted", $new-document)


