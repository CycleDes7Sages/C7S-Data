xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";


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


declare function local:update-div-ids($doc as document-node()) as document-node() {
  document {
    element { node-name($doc/*) } {
      $doc/*/@*,
      for $node in $doc/*/node()
      return local:process-node($node)
    }
  }
};


declare function local:process-node($node as node()) as node() {
  typeswitch ($node)
    case element(tei:div) return
      let $head := $node/tei:head
      let $id := if ($head/@n) then $head/@n else ()
      return
        element { node-name($node) } {
          $node/@* except $node/@xml:id,
          if ($id) then attribute xml:id { $id } else (),
          for $child in $node/node()
          return local:process-node($child)
        }
    case element(tei:p) return
      let $id := $node/@n
      return
        element { node-name($node) } {
          $node/@* except $node/@xml:id,
          if ($id) then attribute xml:id { $id } else (),
          $node/node()
        }
    case element() return
      element { node-name($node) } {
        $node/@*,
        for $child in $node/node()
        return local:process-node($child)
      }
    default return $node
};
    


let $collection-path := "/db/apps/C7S-data"
let $collection := collection($collection-path)
let $target-path := "data-converted"


let $root := if (xmldb:collection-available($target-path)) then ()
      else xmldb:create-collection($collection-path, $target-path)



return
for $doc in $collection
let $new-document := local:update-div-ids($doc)
return 
      local:create-path(document-uri($doc), $collection-path, $collection-path || "/" || $target-path, $new-document)


