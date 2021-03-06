[tags]: haxe,javascript,node,flash,actionscript,ocaml,gamedev,successtory
[disqus]: 114624037180
[lang]: ru

# История успеха с Haxe

**NOTE: This is a russian translation of my [original article](./2015-03-12_haxe-success.html) about Haxe.**

Многие знают, что я большой фанат [Haxe](http://haxe.org/) и стараюсь активно участвовать в его разработке. Но история о том как я до этого дошел (я думаю) довольно интересна, её даже можно назвать "историей успеха" Haxe, так что давайте я расскажу. :-)

## Немного предыстории

Буду краток. Я изучал C/C++ будучи студентом, потом влюбился в Python, когда Ubuntu стали его продвигать (тогда я был фанатом linux), поэтому я нашел работу связанную с Python и некоторе время занимался веб-программированием. Однако я всегда хотел делать игры и постоянно искал игровые вакансии, на которые меня бы взяли. В итоге я начал писать на Python серверы и админки для социальных флеш-игр. Потом я изучил AS3, чтобы помогать коллегам с клиентом и через какое-то время стал клиентским программистом на Flash/AS3 (при этом продолжая писать серверы на Python для этих игр).

## Общий код

Когда я писал на AS3+Python, у меня не было буквально НИКАКОГО общего кода, был "тонкий клиент" на Flash и сервер на Python, который всё просчитывал и изменял игровое состояние. Можно представить насколько неэффективно и нудно это развивать и поддерживать, но тогда я не знал лучших решений.

Потом я присоединился к команде, которая также разрабатывала флеш-игры на AS3, но в ней был один очень умный парень (привет, Денис!) который обладал кое-какими реальными знаниями и понимал, что AS3 является надмножеством ECMAScript (JavaScript) и поэтому можно написать игровую логику на чистом JavaScript, а потом скомпилировать её компиляторм AS3 для флеш-клиента и как-либо интерпретировать на сервере (мы использовали сначала Ruby+TheRubyRacer, потом node.js).

## Написание JavaScript

Эта идея казалось блестящей и по началу очень хорошо работала, но (мягко говоря) JavaScript - не слишком хороший язык для поддержки больших кодовых баз, как у нас, в основном из-за своей динамической натуры. Он требует очень много внимания, дисциплины и тестирования для содержания кодовой базы и поддержания её стабильности. Кроме того, нам приходилось писать довольно много ран-тайм проверок, чтобы убедиться что ничего не сломается из-за маленькой ошибки программиста (кстати, в какой-то момент для нас это стало проблемой быстродействия).

## Типизация JavaScript

Примерно в то время, мой друг рассказал мне о Haxe (тогда еще версии 2.11), какой он клёвый в сочетании с NME, как он может компилироваться в Flash, JS и C++, и т.п., поэтому я решил взглянуть. После недолгого изучения, я был впечатлён возможностью генерировать как JS так и SWF из языка, похожего по синтаксису, но гораздо более продвинутого чем ActionScript 3.

Поэтому мы (с коллегой) разработали прототип системы сборки, позволявшей нам постепенно, кусок за куском портировать нашу кодовую базу с JS на Haxe и компилировать её сначала с помощью AS3-компилятора, будто это JS (вместе с еще не портированными частями), а потом, когда портирование будет окончено - прямо в SWF с помощью Haxe.

Однако этот прототип был отвергнут тимлидом, который решил перейти на TypeScript, у которого было преимущество в том, что он является надмножеством JavaScript и таким образом (теоретически) позволял гораздо легче портировать наш код, а так же имел логотип Microsoft, красовавшийся на его сайте. :-)

Но к портированию мы так и не приступили, а проект был закрыт. Меня перевели работать над Unity проектом в той же компании.

## Unity

Я присоединился к находящемуся в разработке проекту мобильной игры на Unity. Его команде поручили по максимуму реюзать архитектуру сервера и общей логики из Flash+JS игры, о которой я писал выше, поэтому они прикрутили движок JavaScriptCore в Unity игру и стали писать игровую логику на JavaScript. Для них это было противоествественно (они убежденные разработчики на Unity и фанаты C#), но это работало.

Я же получил задачу сделать чтобы всё работало в веб-плеере Unity, чтобы мы могли выпустить игру на Facebook. Удивительно, но из-за использования JavaScript это было практически невозможно по нескольким причинам:
  
 * Веб-плеер Unity не позволяет использовать нативные плагины, такие как JavaScriptCore
 * Реализации JavaScript на .NET не работали, потому что использовали ран-тайм генерацию кода, которая так же запрещена в веб-плеере Unity
 * Использование JS-движка браузера было фактически невозможно для таких сложных вещей, из-за асинхронной природы взаимодействия `Unity<->Браузер`, которая конфликтовала с нашей синхронной архитектурой игровой логики. Кроме того, мы конечно не хотели иметь дело с разным поведением различных браузеров и их плагинов, установленных у тысячей пользователей по всему миру.

## Продвижение Haxe

Уже тогда я был (начинающим) фанатом Haxe и пытался убедить коллег оценить его потенциал, но меня до этого момента никто не воспринимал всерьёз. Я честно пытался найти возможность заставить нашу кодовую базу на JS работать в веб-плеере Unity, но безуспешно.

Итак, я разработал небольшой "proof of concept" на Haxe, который фактически копировал нашу JavaScript-архитектуру. Я скомпилировал его в  C# и JavaScript, чтобы показать что он может одинаково работать в веб-плеере Unity, нативном плагине JavaScriptCore и сервере на node.js. Результаты удивили даже меня - оно просто заработало!

Когда я показал прототим ведущему программисту, он заинтересовался этим решением и наконец решил присмотреться к технологии Haxe. После консультации с главным техдиром, они решили попробовать.

## Портирование с JavaScript на Haxe

Слава богу, архитектура нашего JavaScript-кода не была безумна, как некоторые проекты на JS, доступные сегодня. Она была довольно простой, больше в Java-стиле, поэтому нам не пришлось сильно ломать голову над тем как же портировать её на Haxe.

Но несмотря на это, кодовая база уже была достаточно большой и её портирование занимало время. В связи с этим мы решили сделать следующее: вставлять сгенерированный haxe код прямо в рукописный JavaScript, сделать так чтобы они работали вместе, чтобы таким образом мы могли портировать код по частям.

Мы брали .js файл, портировали его на Haxe, удаляли .js-файл и коммитили, чтобы люди, работающие над проектом случайно не меняли устаревший код. Таким образом после двух недель активной работы, мы (я и мой коллега-единомышленник, Миша) переписали весь код с JS на Haxe при этом не прерывая разработку самой игры остальной командой!

В то время мы не слишком задумывались над правильной типизацией или генерацией кода макросами, потому что нашей главной заботой было сделать так чтобы сгенерированный код вел себя точно так же как оригинальный JS код, дабы не привносить новые баги при портировании. Мы отсматривали сгенерированный код после каждого сеанса портирования и сравнивали его с оригинальным js-кодом. Мы добавляли указания типов в очевидных местах, но по большей части, код оставался динамическим.

## Финальная доработка портированного кода

По завершении портирования JS кода на Haxe, мы должны были скомпилировать его в C# и собрать .NET dll для использования в веб-плеере Unity. После нескольких небольших фиксов, оно скомпилировалось и неплохо заработало. Мы были ОЧЕНЬ довольны, а технология Haxe показала себя многообещающей, однако сгенерированнй C# код был довольно уродлив и неэффективен, потому что... ээ, ну потому что по сути это был C#, написанный в яром динамическом стиле, явно вдохновлённым JavaScript'ом.

Чтение и профайлинг получившегося C# кода показали, что большая часть проблем заключалась в двух вещах:

 - ненужные преобразования (касты) и динамическая работа с объектами
 - много рантайм проверок динамических значений, а так же копирования данных для защиты от ошибок программистов
 
Первая причина была устранена с помощью указания правильных типов в портированном коде и минимизации использования рефлекшена. Система типов Haxe позволила нам описать всё что мы имели в JS в типизированной манере. А в качестве КРУТЕЙШЕГО БОНУСА, добавление правильных типов выявило несколько багов, которые присутствовали в JS коде, но теперь отлавливались компилятором, что позволило нам исправить их до того как их найдут QA (или пользователи, что еще хуже).

Из-за второй причины я начал изучать систему макросов Haxe, я написал несколько макросов, позволивших нам избавиться от большой части рантайм-кода, например:

 - валидация файлов конфигурации игры во время сборки (таким образом мы уверены что JSON-файлы от геймдизайнеров содержат правильные поля со значнеиями правильных типов, без ошибок и опечаток)
 - генерация проверок аргументов в одной точке входа (таким образом, когда кто-то пишет новую "команду" игровой логики, он может быть уверен, что ей будут переданы необходимые аргументы нужных типов, без написания допольнительного кода проверки)
 - [доступ только для чтения, проверяемый на этапе компиляции](https://gist.github.com/nadako/9200026) (таким образом отпала необходимость копировать объекты во избежание их случайного изменения)
 
Возможно макросов было больше, сейчас я уже даже не помню, но с помощью них я познал, насколько мощен Haxe и насколько компактнее и при этом надежднее И эффективнее может быть Haxe-код, в сравнении с JavaScript и даже C#.

Не говоря уже о том, насколько весело было автоматизировать все эти вещи. Любой программист должен от этого балдеть. :)

## Разработка на Haxe

Несмотря на то что Unity-клиент той игры все-таки написан на C#, значительная часть игрового кода написана на Haxe и они очень хорошо работают вместе. Та же история и на сервере - сам сервер написан на JavaScript (node.js), но он использует JS-модуль с игровой логикой, скомпилированный из Haxe. Эта связка успешно работает уже около 2-х лет.

Команда была очень счастлива перейти с JavaScript (который они ненавидели, т.к. являлись фанатами C#) на что-то хорошо типизированное и структурированное, а благодаря проверкам времени компиляции, дальнейшая разработка стала гораздо надежнее и быстрее (меньше багов -> меньше времени, потраченного на их выявление и исправление). Кругом одни плюсы.

## Распространение Haxe

С тех пор я поменял место работы, но я всё еще делаю игры на Unity с использованием Haxe и C#. Я работаю в команде, частично собранной из тех же ребят, с которыми я работал до этого, так что убедить их остаться с Haxe было нетрудно. Мы разработали обновлённую версию нашей архитектуры общей игровой логики, включающую в себя еще больше кодогенерации, строгой типизации и проверок во время компиляции, всё сильнее уменьшая размер кодовой базы и делая вещи более защищенными от ошибок.

Пока что это работает насктолько хорошо, что мы поделились нашей системой на базе Haxe с еще двумя командами/проектами внутри нашей компании, так что люди изучают Haxe и его клёвые возможности. Для такого ярого сторонника Haxe как я, можно сказать "миссия выполнена". :-)

## Профессиональное развитие

Во время портирования и дальнейшей разработки, мы обнаружили некоторое количество багов и узких мест в стандартной библиотеке Haxe и в самом компиляторе. По началу я репортил их на Github и придумывал обходные пути, но в какой-то момент я подумал: "ведь я же вроде неплохой программист, а Haxe - open-source проект, так зачем мне ждать пока кто-то исправит мои баги? Не могу ли я просто пофиксить всё сам?"

Для меня это был нелегкий процесс. Я узнал, что Haxe написан на OCaml, с которым я практически не имел опыта, как и с функциональным программированием вообще. Кроме того, я слабо представлял как работает компилятор, поэтому я просто стал читать куски исходного кода  Haxe по вечерам, оставляя открытым учебник по OCaml в отдельной вкладке браузера, я присоединился к IRC-каналу #haxe, встретившись там с разработчиками Haxe, которые были очень приветливы и ОЧЕНЬ многим мне помогли на моём пути к понимаю OCaml-кода и устройства Haxe (спасибо, Simon и Caue!).

Я обнаружил большое количество классных приемов программирования, необычных для мира JS/AS3/C#, таких как: null-безопасность, алгебраические типы, паттерн-матчинг, неизменность данных, вывод типов, структурная типизация. А что еще приятнее - все эти вещи либо уже присутствуют и готовы к использованию в Haxe, либо могут быть относительно просто реализованы с помощью макросов.

Я понял что такое по-настоящему строгая типизация, изучил новые парадигмы программирования, как лучше организовывать код, как работают компиляторы, насколько полезными могут быть проверки времени компиляции, не говоря уже о новом языке программирования. Всё это действительно сделало меня лучше как прораммиста, в отличие от работы с Unity (хехе).

И да, теперь я активный участник open-sourcе проекта и очень горжусь собой! :)
