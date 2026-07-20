def finish:
  .label = (
    ([
      .labels[]
      | select(
          .value != null
          and ((.language // "") | test("^en(?:-|$)"))
        )
      | .value
    ][0])
    // ([
      .labels[]
      | select(.value != null and .language == null)
      | .value
    ][0])
  )

  | if (
      .emitted == false
      and .geographic
      and .authorized
      and .id != null
      and (.id | startswith($prefix))
      and .label != null
    )
    then
      .out = [
        .label,
        (.id | ltrimstr($prefix))
      ]
      | .emitted = true
    else .
    end;

(foreach inputs as $x (
  {
    idx: null,
    id: null,
    geographic: false,
    authorized: false,
    labels: {},
    label: null,
    emitted: false,
    out: null
  };

  ($x[0] // []) as $p
  | .out = null

  | if ($p == ["@graph"])
    then
      .idx = null
      | .id = null
      | .geographic = false
      | .authorized = false
      | .labels = {}
      | .label = null
      | .emitted = false
    elif (
      ($x | length) == 1
      and ($p | length) == 2
      and $p[0] == "@graph"
      and ($p[1] | type) == "number"
    )
    then
      finish
    elif (
      ($p | length) >= 3
      and $p[0] == "@graph"
      and ($p[1] | type) == "number"
    )
    then
      if .idx != $p[1]
      then
        finish
        | .idx = $p[1]
        | .id = null
        | .geographic = false
        | .authorized = false
        | .labels = {}
        | .label = null
        | .emitted = false
      else .
      end

      | if (
          ($x | length) == 2
          and ($p | length) == 3
          and $p[2] == "@id"
        )
        then .id = $x[1]
        else .
        end

      | if (
          $p[2] == "@type"
          and $x[1] == "madsrdf:Geographic"
        )
        then .geographic = true
        else .
        end

      | if (($x | length) == 2 and $p[2] == "madsrdf:authoritativeLabel")
        then
          if (($p | length) == 3)
          then .labels.direct.value = $x[1]
          elif (($p | length) == 4 and ($p[3] | type) == "number")
          then .labels[($p[3] | tostring)].value = $x[1]
          elif (($p | length) == 4 and $p[3] == "@value")
          then .labels.direct.value = $x[1]
          elif (($p | length) == 4 and $p[3] == "@language")
          then .labels.direct.language = $x[1]
          elif (
            ($p | length) == 5
            and ($p[3] | type) == "number"
            and $p[4] == "@value"
          )
          then .labels[($p[3] | tostring)].value = $x[1]
          elif (
            ($p | length) == 5
            and ($p[3] | type) == "number"
            and $p[4] == "@language"
          )
          then .labels[($p[3] | tostring)].language = $x[1]
          else .
          end
        else .
        end

      | if (
          ($x | length) == 2
          and ($p | length) >= 4
          and $p[2] == "madsrdf:isMemberOfMADSCollection"
          and $p[-1] == "@id"
          and $x[1] == $collection
        )
        then .authorized = true
        else .
        end
    else .
    end;

  if .out != null
  then .out | @csv
  else empty
  end
))
