<!-- Week 1, "Bayes' theorem": the textbook formula, then the belief/data version, with
     one more term colored at each click (prior, likelihood, posterior, data). Clicks 2-5
     line up with the definitions on the slide (fragment-index 2-5). The copies are
     stacked in one place and each shows for one click, so an edit to the formula has to
     be made in all five belief/data copies. -->

::: {.r-stack}
::: {.fragment .fade-out fragment-index=1}
$$
P(A \mid B) = \frac{P(B \mid A) \times P(A)}{P(B)}
$$
:::

::: {.fragment .fade-in-then-out fragment-index=1}
$$
P(\text{belief} \mid \text{data})
=
\frac{
P(\text{data} \mid \text{belief})
\;\times\;
P(\text{belief})
}{
P(\text{data})
}
$$
:::

::: {.fragment .fade-in-then-out fragment-index=2}
$$
P(\text{belief} \mid \text{data})
=
\frac{
P(\text{data} \mid \text{belief})
\;\times\;
\class{red}{P(\text{belief})}
}{
P(\text{data})
}
$$
:::

::: {.fragment .fade-in-then-out fragment-index=3}
$$
P(\text{belief} \mid \text{data})
=
\frac{
\class{blue}{P(\text{data} \mid \text{belief})}
\;\times\;
\class{red}{P(\text{belief})}
}{
P(\text{data})
}
$$
:::

::: {.fragment .fade-in-then-out fragment-index=4}
$$
\class{green}{P(\text{belief} \mid \text{data})}
=
\frac{
\class{blue}{P(\text{data} \mid \text{belief})}
\;\times\;
\class{red}{P(\text{belief})}
}{
P(\text{data})
}
$$
:::

::: {.fragment fragment-index=5}
$$
\class{green}{P(\text{belief} \mid \text{data})}
=
\frac{
\class{blue}{P(\text{data} \mid \text{belief})}
\;\times\;
\class{red}{P(\text{belief})}
}{
\class{gray}{P(\text{data})}
}
$$
:::
:::
