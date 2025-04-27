xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";


let $collection := collection("/db/apps/C7S-data/data")

let $tagNames :=
for $doc in $collection
return distinct-values($doc/tei:TEI//tei:text//*/name())

let $elements :=
    for $doc in $collection
    for $el in $doc//*
    
        let $all :=
        <element-info>
        <file>{base-uri($doc)}</file>
        <name>{name($el)}</name>
        <attributes> {
            for $attr in ($el/@*[not(name() = ("xml:id", "n"))])
            return <attribute name="{name($attr)}" value="{$attr}" />}
        </attributes>
        </element-info>
        return $all


(:    for $tag in $tagNames:)
(:    return:)
(:    <tag-info>:)
(:    <name>{$tag}</name>:)
(:    <attributes>:)
(:    {$elements/attribute}:)
(:    </attributes>:)
(:    </tag-info>:)
let $grouped := 
  for $name in distinct-values($elements/name)
  let $matching := $elements[name = $name]
  let $attrs := distinct-values($matching/attributes/attribute/@name)
  return
    <tag name="{$name}">
      {
        for $a in $attrs
        order by $a
        return <attribute name="{$a}"/>
      }
    </tag>

return 
(:    $grouped:)
    for $tag in $grouped
    let $attribs := 
    for $a in $tag/attribute return $a/@name
    let $attrib-list := string-join( $tag/attribute/@name, ", ")
    let $attrib-list := if ($attrib-list) then   ": " ||  $attrib-list else $attrib-list
    
    return
        $tag/@name || $attrib-list

