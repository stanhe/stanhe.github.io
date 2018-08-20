{% if page.comments %}
  <div class="comments" id="comments">
    {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
      <div class="ds-thread" data-thread-key="{{ page.path }}"
           data-title="{{ page.title }}" data-url="{{ page.permalink }}">
      </div>
    {% elseif theme.disqus_shortname %}
      <div id="disqus_thread">
        <noscript>
          Please enable JavaScript to view the
          <a href="//disqus.com/?ref_noscript">comments powered by Disqus.</a>
        </noscript>
      </div>
    {% endif %}
  </div>

  <!-- 多说评论框 start -->
    <div class="ds-thread" data-thread-key="{{ page.path }}"
             data-title="{{ page.title }}" data-url="{{ page.permalink }}">
        </div>
  <!-- 多说评论框 end -->
  <!-- 多说公共JS代码 start (一个网页只需插入一次) -->
  <script type="text/javascript">
  var duoshuoQuery = {short_name:"stanhe"};
  	(function() {
  		var ds = document.createElement('script');
  		ds.type = 'text/javascript';ds.async = true;
  		ds.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//static.duoshuo.com/embed.js';
  		ds.charset = 'UTF-8';
  		(document.getElementsByTagName('head')[0]
  		 || document.getElementsByTagName('body')[0]).appendChild(ds);
  	})();
  	</script>
  <!-- 多说公共JS代码 end -->

{% endif %}
